import java.time.LocalDate
import java.time.format.DateTimeParseException
import java.util.Base64

@JvmInline value class TaskId private constructor(val text: String) {
    companion object {
        fun parse(raw: String): TaskId {
            require(raw.matches(Regex("[A-Za-z0-9]+"))) { "id" }
            return TaskId(raw)
        }
    }
}
@JvmInline value class ProjectName private constructor(val text: String) {
    companion object {
        fun parse(raw: String): ProjectName {
            require(raw.matches(Regex("[A-Za-z][A-Za-z ]*"))) { "project" }
            return ProjectName(raw)
        }
    }
}
@JvmInline value class TaskTitle private constructor(val text: String) {
    companion object {
        fun parse(raw: String): TaskTitle {
            require(raw.isNotBlank() && !raw.contains('|') && !raw.contains(';') && !raw.contains('@')) { "title" }
            return TaskTitle(raw)
        }
    }
}
@JvmInline value class DueDate private constructor(val value: LocalDate) {
    companion object {
        fun parse(raw: String): DueDate = try {
            require(raw.matches(Regex("[0-9]{4}-[0-9]{2}-[0-9]{2}"))) { "date" }
            DueDate(LocalDate.parse(raw))
        } catch (_: DateTimeParseException) { throw IllegalArgumentException("date") }
    }
}

data class TaskView(val id: TaskId, val project: ProjectName, val title: TaskTitle,
                    val deadline: DueDate?, val done: Boolean, val sequence: Int) {
    fun serialize(): String = "${id.text}@${project.text}@${title.text}@${deadline?.value ?: "-"}@${if (done) 1 else 0}"
}

class TaskBook {
    private val projects = linkedSetOf<ProjectName>()
    private val tasks = linkedMapOf<TaskId, TaskView>()
    private var nextSequence = 0
    fun addProject(name: ProjectName) {
        require(projects.add(name)) { "duplicate-project" }
    }
    fun addTask(project: ProjectName, id: TaskId, title: TaskTitle) {
        require(project in projects) { "missing-project" }
        require(id !in tasks) { "duplicate-id" }
        tasks[id] = TaskView(id, project, title, null, false, nextSequence++)
    }
    fun complete(id: TaskId) {
        val task = tasks[id] ?: throw IllegalArgumentException("missing-task")
        tasks[id] = task.copy(done = true)
    }
    fun deadline(id: TaskId, date: DueDate) {
        val task = tasks[id] ?: throw IllegalArgumentException("missing-task")
        tasks[id] = task.copy(deadline = date)
    }
    fun delete(id: TaskId) {
        require(tasks.remove(id) != null) { "missing-task" }
    }
    fun today(date: DueDate): List<TaskView> = tasks.values
        .filter { !it.done && it.deadline == date }
        .sortedWith(compareBy<TaskView> { it.project.text }.thenBy { it.id.text })
    fun byProject(): List<TaskView> = projects.flatMap { project ->
        tasks.values.filter { it.project == project }.sortedBy { it.sequence }
    }
    fun byDeadline(): List<TaskView> = tasks.values.filter { it.deadline != null }
        .sortedWith(compareBy<TaskView> { it.deadline!!.value }.thenBy { it.id.text })
    fun byDate(): List<TaskView> = tasks.values.sortedWith(
        compareBy<TaskView> { it.deadline == null }.thenBy { it.deadline?.value }
            .thenBy { it.id.text }
    )
}

object TaskProtocol {
    fun execute(script: String): String {
        val book = TaskBook()
        val result = mutableListOf<String>()
        for (line in script.split('\n')) {
            if (line.isEmpty()) continue
            val fields = line.split('|')
            try {
                val response = when (fields[0]) {
                    "project" -> { require(fields.size == 2) { "arity" }; book.addProject(ProjectName.parse(fields[1])); "OK" }
                    "add" -> { require(fields.size == 4) { "arity" }; book.addTask(ProjectName.parse(fields[1]), TaskId.parse(fields[2]), TaskTitle.parse(fields[3])); "OK" }
                    "done" -> { require(fields.size == 2) { "arity" }; book.complete(TaskId.parse(fields[1])); "OK" }
                    "deadline" -> { require(fields.size == 3) { "arity" }; book.deadline(TaskId.parse(fields[1]), DueDate.parse(fields[2])); "OK" }
                    "delete" -> { require(fields.size == 2) { "arity" }; book.delete(TaskId.parse(fields[1])); "OK" }
                    "today" -> { require(fields.size == 2) { "arity" }; "LIST:" + book.today(DueDate.parse(fields[1])).joinToString(";") { it.serialize() } }
                    "view" -> {
                        require(fields.size == 2) { "arity" }
                        val items = when (fields[1]) {
                            "project" -> book.byProject()
                            "deadline" -> book.byDeadline()
                            "date" -> book.byDate()
                            else -> throw IllegalArgumentException("view")
                        }
                        "LIST:" + items.joinToString(";") { it.serialize() }
                    }
                    else -> "ERR:command"
                }
                result.add(response)
            } catch (e: IllegalArgumentException) {
                result.add("ERR:${e.message ?: "invalid"}")
            }
        }
        return result.joinToString("\n")
    }
}

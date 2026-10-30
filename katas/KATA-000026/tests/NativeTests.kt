object NativeTests {
    private var count = 0
    private fun expect(script: String, wanted: String) {
        count++
        val got = TaskProtocol.execute(script)
        if (got != wanted) error("behavior expected=$wanted got=$got script=$script")
    }
    @JvmStatic fun main(args: Array<String>) {
        expect("project|Work", "OK")
        expect("project|Work\nproject|Work", "OK\nERR:duplicate-project")
        expect("project|Work\nadd|Work|T1|Write", "OK\nOK")
        expect("add|Work|T1|Write", "ERR:missing-project")
        expect("project|Work\nadd|Work|T1|Write\nadd|Work|T1|Again", "OK\nOK\nERR:duplicate-id")
        expect("project|Work\nadd|Work|bad id|Write", "OK\nERR:id")
        expect("project|Work\nadd|Work|T1|Write\ndeadline|T1|2026-02-30", "OK\nOK\nERR:date")
        expect("project|Work\nadd|Work|T1|Write\ndeadline|T1|2026-11-01\ntoday|2026-11-01", "OK\nOK\nOK\nLIST:T1@Work@Write@2026-11-01@0")
        expect("project|Work\nadd|Work|T1|Write\ndeadline|T1|2026-11-01\ndone|T1\ntoday|2026-11-01", "OK\nOK\nOK\nOK\nLIST:")
        expect("project|Work\nadd|Work|T1|Write\ndelete|T1\nview|project", "OK\nOK\nOK\nLIST:")
        expect("delete|T1", "ERR:missing-task")
        expect("deadline|T1|2026-11-01", "ERR:missing-task")
        expect("done|T1", "ERR:missing-task")
        expect("project|Work\nadd|Work|T1|Write\nview|deadline", "OK\nOK\nLIST:")
        expect("project|Work\nadd|Work|T1|Write\nview|date", "OK\nOK\nLIST:T1@Work@Write@-@0")
        expect("project|Work\nadd|Work|A|Alpha\nadd|Work|B|Beta\nadd|Work|C|Gamma\ndelete|A\ndelete|B\nadd|Work|D|Delta\nview|project", "OK\nOK\nOK\nOK\nOK\nOK\nOK\nLIST:C@Work@Gamma@-@0;D@Work@Delta@-@0")
        expect("view|bad", "ERR:view")
        expect("project|Work|extra", "ERR:arity")
        expect("project|Bad123", "ERR:project")
        expect("project|Work\nadd|Work|T1|Bad@title", "OK\nERR:title")
        expect("project|Work\nadd|Work|T1|Write\ndeadline|T1|2024-02-29\nview|deadline", "OK\nOK\nOK\nLIST:T1@Work@Write@2024-02-29@0")
        println("GREEN Kotlin $count native assertions")
    }
}

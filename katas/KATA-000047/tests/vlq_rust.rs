// SPDX-License-Identifier: MIT
//! Additive Rust implementation of the existing educational u32 VLQ contract.
use std::io::{self, BufRead};
fn encode(values: &[u64]) -> Result<Vec<u64>, ()> {
    let mut output = Vec::new();
    for &value in values {
        if value > u32::MAX as u64 {return Err(());}
        let mut n = value;
        let mut digits = Vec::new();
        loop {
            digits.push(n % 128);
            n /= 128;
            if n == 0 {break;}
        }
        for (index, digit) in digits.iter().rev().enumerate() {
            output.push(*digit + if index + 1 < digits.len() {128} else {0});
        }
    }
    Ok(output)
}
fn decode(bytes: &[u64]) -> Result<Vec<u64>, ()> {
    let mut out=Vec::new();
    let mut current=0_u64;
    let mut groups=0_usize;
    for &b in bytes {
        if b>255 {return Err(());}
        groups+=1;
        if groups>5 || (groups==1 && b>=128 && b%128==0) {return Err(());}
        current = current.checked_mul(128).ok_or(())?
            .checked_add(b%128).ok_or(())?;
        if current>u32::MAX as u64 {return Err(());}
        if b<128 {
            out.push(current);
            groups=0;current=0;
        }
    }
    if groups!=0 {return Err(());}
    Ok(out)
}
fn process(line:&str)->Result<Vec<u64>,()> {
    let (mode,rest)=line.split_once('|').ok_or(())?;
    let data:Vec<u64>=if rest.is_empty(){Vec::new()}else{
        rest.split(',').map(|v|v.parse::<u64>().map_err(|_|())).collect::<Result<_,_>>()?
    };
    match mode {
        "E"=>encode(&data),
        "D"=>decode(&data),
        _=>Err(())
    }
}
fn main(){
    for line in io::stdin().lock().lines(){
        let line=match line{Ok(v)=>v,Err(_)=>break};
        match process(&line){
            Ok(vals)=>{
                let s=vals.iter().map(u64::to_string).collect::<Vec<_>>().join(",");
                println!("OK|{}",s);
            }
            Err(_)=>println!("ERROR"),
        }
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test] fn boundary() {
        assert_eq!(encode(&[0,127,128,16383,16384,4294967295]).unwrap(),
            vec![0,127,129,0,255,127,129,128,0,143,255,255,255,127]);
        assert_eq!(decode(&[129,0,127,143,255,255,255,127]).unwrap(),
            vec![128,127,4294967295]);
    }
    #[test] fn reject_noncanonical_or_truncated(){
        for bytes in [&[128_u64][..],&[128,0][..],&[129,128,128,128,128,0][..],
                      &[144,128,128,128,0][..],&[256][..]] {
            assert!(decode(bytes).is_err());
        }
        assert!(encode(&[4294967296]).is_err());
    }
}

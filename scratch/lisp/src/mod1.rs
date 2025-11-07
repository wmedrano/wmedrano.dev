use std::sync::Arc;

use crate::Function;
use crate::RustFunction;

#[derive(Clone, Debug, PartialEq)]
pub enum Val {
    Int(i64),
    Bool(bool),
    Symbol(String),
    List(Vec<Val>),
    RustFunction(Arc<RustFunction>),
    Function(Arc<Function>),
}

impl From<RustFunction> for Val {
    fn from(f: RustFunction) -> Val {
        Val::RustFunction(Arc::new(f))
    }
}

#[test]
fn test_tokenizer() {
    let tokenizer = Tokenizer::new("12 #true (+ 1 2)");
    assert_eq!(
        tokenizer.collect::<Vec<_>>(),
        &["12", "#true", "(", "+", "1", "2", ")"]
    );
}

#[derive(Debug, Clone)]
pub struct Tokenizer<'a> {
    input: &'a str,
    position: usize,
}

impl<'a> Iterator for Tokenizer<'a> {
    type Item = &'a str;

    fn next(&mut self) -> Option<Self::Item> {
        // Skip whitespace.
        if let Some(offset) = self.input[self.position..]
            .chars()
            .position(|c| !c.is_whitespace())
        {
            self.position += offset
        }
        if self.position >= self.input.len() {
            return None;
        }

        // Handle parens
        let start = self.position;
        let ch = &self.input[start..start + 1];
        if matches!(ch, "(" | ")") {
            self.position += 1;
            return Some(ch);
        }
        // Handle identifiers
        let token = self
            .input
            .get(start..)?
            .split(|c: char| c.is_whitespace() || c == '(' || c == ')')
            .next()?;
        self.position += token.len();
        Some(token)
    }
}

impl<'a> Tokenizer<'a> {
    pub fn new(input: &'a str) -> Self {
        Self { input, position: 0 }
    }
}

#[test]
fn test_read() {
    let mut tokenizer = Tokenizer::new("42 #true + (+ (* 2 3) 4)");
    assert_eq!(read_next(&mut tokenizer).unwrap(), Some(Val::Int(42)));
    assert_eq!(read_next(&mut tokenizer).unwrap(), Some(Val::Bool(true)));
    assert_eq!(
        read_next(&mut tokenizer).unwrap(),
        Some(Val::Symbol("+".to_string()))
    );
    assert_eq!(
        read_next(&mut tokenizer).unwrap(),
        Some(Val::List(vec![
            Val::Symbol("+".to_string()),
            Val::List(vec![Val::Symbol("*".to_string()), Val::Int(2), Val::Int(3)]),
            Val::Int(4)
        ]))
    );
    assert_eq!(read_next(&mut tokenizer).unwrap(), None);
}

#[test]
fn test_read_unmatched_paren() {
    let mut tokenizer = Tokenizer::new("(+ 1 2");
    assert!(matches!(
        read_next(&mut tokenizer),
        Err(TokenizerError::UnexpectedEndOfInput)
    ));
}

#[test]
fn test_read_extra_closing_paren() {
    let mut tokenizer = Tokenizer::new(")");
    assert!(matches!(
        read_next(&mut tokenizer),
        Err(TokenizerError::UnexpectedEndOfInput)
    ));
}

#[derive(Copy, Clone, Debug, PartialEq)]
pub enum TokenizerError {
    UnexpectedEndOfInput,
}

pub fn read_next(tokenizer: &mut Tokenizer) -> Result<Option<Val>, TokenizerError> {
    match read_next_impl(tokenizer)? {
        ReadItem::EndExpr => Err(TokenizerError::UnexpectedEndOfInput),
        ReadItem::Atom(val) => Ok(Some(val)),
        ReadItem::None => Ok(None),
    }
}

enum ReadItem {
    EndExpr,
    Atom(Val),
    None,
}

fn read_next_impl(tokenizer: &mut Tokenizer) -> Result<ReadItem, TokenizerError> {
    match tokenizer.next() {
        None => Ok(ReadItem::None),
        Some("#true") => Ok(ReadItem::Atom(Val::Bool(true))),
        Some("#false") => Ok(ReadItem::Atom(Val::Bool(false))),
        Some("(") => {
            let mut res = Vec::new();
            loop {
                match read_next_impl(tokenizer)? {
                    ReadItem::EndExpr => return Ok(ReadItem::Atom(Val::List(res))),
                    ReadItem::Atom(v) => res.push(v),
                    ReadItem::None => return Err(TokenizerError::UnexpectedEndOfInput),
                }
            }
        }
        Some(")") => Ok(ReadItem::EndExpr),
        Some(identifier @ _) => {
            let val = if let Ok(int_val) = identifier.parse::<i64>() {
                Val::Int(int_val)
            } else {
                Val::Symbol(identifier.to_string())
            };
            Ok(ReadItem::Atom(val))
        }
    }
}

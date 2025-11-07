use std::collections::HashMap;
use std::sync::{Arc, Mutex};

pub mod mod1;
pub use mod1::*;

#[derive(Default, Clone, Debug)]
pub struct Environment(Arc<EnvironmentInner>);

impl PartialEq for Environment {
    fn eq(&self, other: &Self) -> bool {
        Arc::ptr_eq(&self.0, &other.0)
    }
}

#[derive(Default, Debug)]
struct EnvironmentInner {
    pub parent: Option<Environment>,
    pub values: Mutex<HashMap<String, Val>>,
}

impl Environment {
    pub fn new(values: impl Iterator<Item = (String, Val)>) -> Environment {
        let values: HashMap<String, Val> = HashMap::from_iter(values);
        Environment(Arc::new(EnvironmentInner {
            parent: None,
            values: Mutex::new(values),
        }))
    }

    pub fn with_child(&self, values: impl Iterator<Item = (String, Val)>) -> Environment {
        let values: HashMap<String, Val> = HashMap::from_iter(values);
        Environment(Arc::new(EnvironmentInner {
            parent: Some(self.clone()),
            values: Mutex::new(values),
        }))
    }

    pub fn define(&self, name: &str, value: Val) {
        let mut values = self.0.values.lock().unwrap();
        values.insert(name.to_string(), value);
    }

    pub fn set(&self, name: &str, value: Val) -> Result<(), Error> {
        let mut values = self.0.values.lock().unwrap();
        if let Some(slot) = values.get_mut(name) {
            *slot = value;
            return Ok(());
        }
        match self.0.parent.as_ref() {
            Some(parent) => parent.set(name, value),
            None => Err(Error::ValueNotFound(name.to_string())),
        }
    }

    pub fn lookup(&self, name: &str) -> Option<Val> {
        {
            let values = self.0.values.lock().unwrap();
            if let Some(v) = values.get(name) {
                return Some(v.clone());
            }
        }
        match self.0.parent.as_ref() {
            Some(p) => p.lookup(name),
            None => None,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
#[allow(unpredictable_function_pointer_comparisons)]
pub struct RustFunction {
    pub func: fn(&[Val]) -> Result<Val, Error>,
}

#[derive(Debug, Clone, PartialEq)]
pub enum Error {
    TokenizerError(TokenizerError),
    ValueNotFound(String),
    ValueNotCallable(Val),
    EmptyFunctionEvaluation,
    WrongType { expected: &'static str, got: Val },
    WrongArity { expected: usize, got: usize },
    BadDefine,
    BadIf,
    BadLambda,
}

impl From<TokenizerError> for Error {
    fn from(e: TokenizerError) -> Error {
        Error::TokenizerError(e)
    }
}

pub fn eval(expr: &Val, env: &Environment) -> Result<Val, Error> {
    match expr {
        Val::Int(_) | Val::Bool(_) | Val::RustFunction(_) | Val::Function(_) => Ok(expr.clone()),
        Val::Symbol(sym) => env.lookup(sym).ok_or(Error::ValueNotFound(sym.to_string())),
        Val::List(expr) => eval_list(expr, env),
    }
}

pub fn eval_list1(expr: &[Val], env: &Environment) -> Result<Val, Error> {
    match expr {
        [] => return Err(Error::EmptyFunctionEvaluation),
        [func_expr, arg_exprs @ ..] => {
            let func_val = eval(func_expr, env)?;
            match func_val {
                Val::RustFunction(func) => {
                    let args = arg_exprs
                        .iter()
                        .map(|expr| eval(expr, env))
                        .collect::<Result<Vec<_>, _>>()?;
                    (func.func)(&args)
                }
                val @ _ => Err(Error::ValueNotCallable(val.clone())),
            }
        }
    }
}

fn eval_list(expr: &[Val], env: &Environment) -> Result<Val, Error> {
    let (func_expr, args) = match expr {
        [] => return Err(Error::EmptyFunctionEvaluation),
        [func_expr, arg_exprs @ ..] => (func_expr, arg_exprs),
    };
    if let Val::Symbol(sym) = func_expr {
        match sym.as_str() {
            "define" => return eval_define(args, env),
            "if" => return eval_if(args, env),
            "lambda" => return eval_lambda(args, env),
            _ => {}
        }
    }

    match eval(func_expr, env)? {
        Val::RustFunction(func) => {
            let args = args
                .iter()
                .map(|expr| eval(expr, env))
                .collect::<Result<Vec<_>, _>>()?;
            (func.func)(&args)
        }
        Val::Function(func) => {
            let args = args
                .iter()
                .map(|expr| eval(expr, env))
                .collect::<Result<Vec<_>, _>>()?;
            func.eval(&args)
        }
        val @ _ => Err(Error::ValueNotCallable(val.clone())),
    }
}

fn eval_define(args: &[Val], env: &Environment) -> Result<Val, Error> {
    match args {
        [Val::Symbol(name), expr @ _] => {
            let val = eval(expr, env)?;
            env.define(&name, val);
            Ok(Val::Symbol(name.clone()))
        }
        _ => Err(Error::BadDefine),
    }
}

fn eval_if(args: &[Val], env: &Environment) -> Result<Val, Error> {
    match args {
        [test_expr @ _, true_expr @ _, false_expr @ _] => match eval(test_expr, env)? {
            Val::Bool(false) => eval(false_expr, env),
            _ => eval(true_expr, env),
        },
        _ => Err(Error::BadIf),
    }
}
fn eval_lambda(args: &[Val], env: &Environment) -> Result<Val, Error> {
    match args {
        [Val::List(args @ _), body @ ..] => {
            let arg_names = args
                .iter()
                .map(|a| match a {
                    Val::Symbol(sym) => Ok(sym.clone()),
                    _ => Err(Error::BadLambda),
                })
                .collect::<Result<_, _>>()?;
            let body = body.iter().cloned().collect();
            Ok(Val::Function(Arc::new(Function {
                base_env: env.clone(),
                arg_names,
                body,
            })))
        }
        _ => Err(Error::BadLambda),
    }
}

#[cfg(test)]
fn eval_str(s: &str, env: &Environment) -> Result<Val, Error> {
    let mut tokenizer = Tokenizer::new(s);
    let expr = read_next(&mut tokenizer)?
        .ok_or(Error::TokenizerError(TokenizerError::UnexpectedEndOfInput))?;
    eval(&expr, env)
}

#[test]
fn eval_atoms_returns_atom() {
    assert_eq!(eval_str("10", &Environment::default()), Ok(Val::Int(10)));
    assert_eq!(
        eval_str("#true", &Environment::default()),
        Ok(Val::Bool(true))
    );
    assert_eq!(
        eval_str("#false", &Environment::default()),
        Ok(Val::Bool(false))
    );
}

#[test]
fn eval_on_symbol_returns_environment_value() {
    let env = Environment::default();
    env.define("variable", Val::Int(42));
    assert_eq!(eval_str("variable", &env), Ok(Val::Int(42)));
}

#[test]
fn eval_on_undefined_symbol_is_error() {
    let env = Environment::default();
    assert_eq!(
        eval_str("undefined", &env),
        Err(Error::ValueNotFound("undefined".to_string()))
    );
}

#[test]
fn eval_on_symbol_returns_latest_value() {
    let env = Environment::default();
    env.define("variable", Val::Int(42));
    assert_eq!(eval_str("variable", &env), Ok(Val::Int(42)));
    env.define("variable", Val::Int(0));
    assert_eq!(eval_str("variable", &env), Ok(Val::Int(0)));
}

#[cfg(test)]
fn add_impl(args: &[Val]) -> Result<Val, Error> {
    let mut res: i64 = 0;
    for arg in args {
        match arg {
            Val::Int(x) => res += x,
            val @ _ => {
                return Err(Error::WrongType {
                    expected: "int",
                    got: val.clone(),
                })
            }
        }
    }
    Ok(Val::Int(res))
}

#[test]
fn eval_function_returns_result() {
    let env = Environment::default();
    env.define("+", RustFunction { func: add_impl }.into());
    assert_eq!(eval_str("(+ 1 2)", &env), Ok(Val::Int(3)));
}

#[test]
fn eval_define_sets_variable() {
    let env = Environment::default();
    assert_eq!(
        eval_str("(define value 42)", &env),
        Ok(Val::Symbol("value".to_string()))
    );
    assert_eq!(eval_str("value", &env), Ok(Val::Int(42)));
}

#[derive(Clone, Debug, PartialEq)]
pub struct Function {
    base_env: Environment,
    arg_names: Vec<String>,
    body: Vec<Val>,
}

impl Function {
    pub fn eval(&self, args: &[Val]) -> Result<Val, Error> {
        if self.arg_names.len() != args.len() {
            return Err(Error::WrongArity {
                expected: args.len(),
                got: self.arg_names.len(),
            });
        }
        let arg_name_values = self
            .arg_names
            .iter()
            .zip(args)
            .map(|(name, val)| (name.to_string(), val.clone()));
        let env = self.base_env.with_child(arg_name_values);
        let mut ret = None;
        for expr in self.body.iter() {
            ret = Some(eval(expr, &env)?);
        }
        Ok(ret.unwrap_or_else(|| Val::Symbol("*unspecified*".to_string())))
    }
}

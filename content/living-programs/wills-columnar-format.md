+++
title = "Will's Columnar Format"
author = ["Will Medrano"]
date = 2023-04-18
lastmod = 2023-04-23T12:49:22-07:00
draft = false
+++

## Introduction {#introduction}

[Will's columnar format](https://wmedrano.dev/living-programs/wills-columnar-format) is a columnar format made by will.s.medrano@gmail.com. It
is primarily implemented for educational purposes. If you are interested in
using a well supported columnar format, consider using [Apache Parquet](https://parquet.apache.org/).


### Conventions {#conventions}

The following conventions are used:

-   All structs are encoded using [Bincode](https://github.com/bincode-org/bincode). Bincode is a binary
    encoding/decoding scheme implemented in Rust.
-   Source code snippets are presented for relatively high level constructs. Lower
    level details may be omitted from presentation.


## API {#api}


### V0 Features {#v0-features}

V0 is roughly implemented but still requires verification, testing, error
handling, and bench-marking.

Supports:

-   Only a single column per encode/decode.
-   `i64` and `String` types.
-   Run length encoding.


### V1 Features Brainstorm {#v1-features-brainstorm}

-   Dictionary encoding for better string compression.
-   Compression (like zstd or snappy) for data.
-   Multiple columns.
-   Push down filtering.
-   Split column data into blocks. Required by push down filtering.


### Encoding {#encoding}

`encode_column` encodes a `Vec<T>` into Will's Columnar Format. If `use_rle` is
true, then run length encoding will be used.

TODO: `use_rle` should have more granular values like `NEVER`, `ALWAYS`, and
`AUTO`.

```rust
pub fn encode_column<T>(data: Vec<T>, use_rle: bool) -> Vec<u8>
where
    T: 'static + bincode::Encode + Eq {
    encode_column_impl(data, use_rle)
}
```


### Decoding {#decoding}

`decode_column` decodes data from a byte stream into a `Vec<T>`.

TODO: Decoding should return an iterator of `(element_count, element)` to
support efficient reads of run-length-encoded data.

```rust
pub fn decode_column<T>(r: &mut impl std::io::Read) -> Vec<T>
where
    T: 'static + Clone + bincode::Decode {
    decode_column_impl(r)
}
```


### Tests {#tests}

```rust
#[test]
fn test_header_contains_magic_bytes() {
    let data: Vec<i64> = vec![1, 2, 3, 4];
    let encoded_data = encode_column(data.clone(), false);
    let encoded_data_magic_bytes = &encoded_data[0..9];
    assert_eq!(encoded_data_magic_bytes, b"wmedrano0");
}
```

```rust
#[test]
fn test_encode_decode_i64() {
    let data: Vec<i64> = vec![-1, 10, 10, 10, 11, 12, 12, 10];
    let encoded_data = encode_column(data.clone(), false);
    assert_eq!(encoded_data.len(), 22);

    let mut encoded_data_cursor = std::io::Cursor::new(encoded_data);
    let decoded_data: Vec<i64> = decode_column(&mut encoded_data_cursor);
    assert_eq!(decoded_data.as_slice(), &[-1, 10, 10, 10, 11, 12, 12, 10]);
}
```

```rust
#[test]
fn test_encode_decode_string() {
    let data: Vec<String> = Vec::from_iter([
        "foo",
        "foo",
        "foo",
        "bar",
        "baz",
        "foo",
    ].into_iter().map(String::from));
    let encoded_data = encode_column(data.clone(), false);
    assert_eq!(encoded_data.len(), 38);

    let mut encoded_data_cursor = std::io::Cursor::new(encoded_data);
    let decoded_data: Vec<String> = decode_column(&mut encoded_data_cursor);
    assert_eq!(
        decoded_data,
        Vec::from_iter(["foo", "foo", "foo", "bar", "baz", "foo"].into_iter().map(String::from)));
}
```

```rust
#[test]
fn test_encode_decode_string_with_rle() {
    let data: Vec<String> = Vec::from_iter([
        "foo",
        "foo",
        "foo",
        "bar",
        "baz",
        "foo",
    ].into_iter().map(String::from));
    let encoded_data = encode_column(data.clone(), true);
    assert_eq!(encoded_data.len(), 34);
    let mut encoded_data_cursor = std::io::Cursor::new(encoded_data);
    let decoded_data: Vec<String> = decode_column(&mut encoded_data_cursor);
    assert_eq!(
        decoded_data,
        Vec::from_iter(["foo", "foo", "foo", "bar", "baz", "foo"].into_iter().map(String::from)));
}
```


## Format Specification {#format-specification}

-   `magic-bytes` - The magic bytes are "wmedrano0".
-   `header` - The header contains metadata about the column.
-   `data` - The encoded column data.


### Header {#header}

The header contains an encoded struct:

```rust
#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub struct Header {
    pub data_type: DataType,
    pub is_rle: bool,
    pub elements: usize,
    pub data_size: usize,
}

#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub enum DataType {
    I64 = 0,
    String = 1,
}
```


### Data {#data}

The data consists of a sequence of encoded data. Encoding happens using the
standard `bincode` package to encode/decode data of type `&[T]` and `Vec<T>`.


#### RLE {#rle}

[Run length encoding](https://en.wikipedia.org/wiki/Run-length_encoding#:~:text=Run%2Dlength%20encoding%20(RLE),than%20as%20the%20original%20run.) is a compression technique for repeated values. For RLE, the
data is encoded as a tuple of `(u16, T)` where the first item contains the run
length and the second contains the element.

TODO: Refactor type from `(u16, T)` to something cleaner like a new custom type,
`RleElement<T>`.

```rust
fn rle_encode_data<T: Eq>(data: impl Iterator<Item = T>) -> Vec<(u16, T)> {
    let mut data = data;
    let mut element = match data.next() {
        Some(e) => e,
        None => return Vec::new(),
    };
    let mut count = 1;

    let mut ret = Vec::new();
    for next_element in data {
        if next_element != element || count == u16::MAX {
            ret.push((count, element));
            (element, count) = (next_element, 1);
        } else {
            count += 1;
        }
    }
    if count > 0 {
        ret.push((count, element));
    }
    ret
}

fn rle_decode_data<'a, T: 'static>(
    iter: impl 'a + Iterator<Item = &'a (u16, T)>,
) -> impl Iterator<Item = &'a T> {
    iter.flat_map(move |(run_length, element)| {
        std::iter::repeat(element).take(*run_length as usize)
    })
}
```


## Source Code {#source-code}

The source code is stored at
<https://github.com/wmedrano/wills-columnar-format>. The main source file is
`wills-columnar-format.org` which is used to generate the `src/lib.rs`.

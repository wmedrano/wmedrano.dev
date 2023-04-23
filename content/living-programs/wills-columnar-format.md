+++
title = "Will's Columnar Format"
author = ["Will Medrano"]
date = 2023-04-18
lastmod = 2023-04-23T09:31:56-07:00
draft = false
+++

## Introduction {#introduction}

[Will's columnar format](https://wmedrano.dev/living-programs/wills-columnar-format) is a columnar format made by will.s.medrano@gmail.com. It
is primarily implemented for educational purposes. If you are interested in
using a well supported columnar format, consider using [Apache Parquet](https://parquet.apache.org/).


### Conventions {#conventions}

The following conventions are used:

-   All structs are encoded using [Bincode](https://github.com/bincode-org/bincode). `bincode` is a binary
    encoding/decoding scheme implemented in Rust.
-   Source code snippets are presented for relatively high level constructs. Lower
    level details may be omitted from presentation.


## API {#api}


### V0 Features {#v0-features}

V0 is implemented but still requires verification, testing, and bench-marking.

Supports:

-   Only a single column per encode/decode.
-   `i64` and `String` types.
-   Run length encoding.


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

`decode_column` decodes data from a `Read` stream into a `Vec<T>`.

TODO: Decoding should return an iterator of `(element_count, element)` to
support efficient reads of run-length-encoded data.

```rust
pub fn decode_column<T>(r: &mut impl std::io::Read) -> Vec<T>
where
    T: 'static + Clone + bincode::Decode {
    decode_column_impl(r)
}
```


## Format Specification {#format-specification}

-   `magic-string` - A magic string of "wmedrano0".
-   `header` - The header.
-   `data` - The data.


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
standard `bincode` package for all data types.


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


#### <span class="org-todo todo TODO">TODO</span> Dictionary Encoding {#dictionary-encoding}

Dictionary encoding is useful for string columns with few unique values. This is
out of scope for V0.


## Source Code {#source-code}

The source code is stored at
<https://github.com/wmedrano/wills-columnar-format>. The main source file is
`wills-columnar-format.org` which is used to generate the `src/lib.rs`.

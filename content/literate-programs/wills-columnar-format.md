+++
title = "Will's Columnar Format"
author = ["Will Medrano"]
date = 2023-04-23
lastmod = 2023-04-25T10:11:11-07:00
draft = false
+++

## Introduction {#Introduction-h6a696o03tj0}

**Will's Columnar Format V0**

[Will's Columnar Format](https://wmedrano.dev/literate-programs/wills-columnar-format) is a columnar format made by will.s.medrano@gmail.com. It
is primarily implemented for educational purposes. If you are interested in
using a well supported columnar format, consider using [Apache Parquet](https://parquet.apache.org/).


### Conventions {#IntroductionConventions-gbb696o03tj0}

The following conventions are used:

-   All structs are encoded using [Bincode](https://github.com/bincode-org/bincode). Bincode is a binary
    encoding/decoding scheme implemented in Rust.
-   Source code snippets are presented for relatively high level constructs. Lower
    level details may be omitted from presentation.


### Building and Testing Library {#IntroductionBuildingandTestingLibrary-r0c696o03tj0}

Will's Columnar Format is programmed in Org mode with Rust code
blocks. Compiling requires:

1.  Emacs - Text editor and lisp environment.
2.  Cargo - The Rust package manager.

To generate the Rust source code, run `M-x org-babel-tangle` for
`wills-columnar-format.org` within Emacs. To automatically tangle the current
file on save, run:

```emacs-lisp
(add-hook 'after-save-hook #'org-babel-tangle 0 t)
```

Building and testing relies on Cargo.

```shell
cargo build
cargo test
cargo test $FN_TO_TEST
```


### Dependencies {#IntroductionCargotoml-cqc696o03tj0}

Rust dependencies are automatically fetched with Cargo. This library depends on
the following crates:

```toml
# Note: Bincode v2 currently in release candidate. This should be bumped to 2.0
# once Bincode v2 is released.
bincode = "2.0.0-rc.3"
itertools = "0.10"
```


## Features {#Features-0ed696o03tj0}


#### V0 Features {#FeaturesV0Features-81e696o03tj0}

V0 is roughly implemented but still requires graceful error handling, and
bench-marking.

Supports:

-   Only a single column per encode/decode.
-   Integer (both signed and unsigned) and String types.
-   Run length encoding.


#### Tentative V1 Features {#FeaturesTentativeV1Features-ppe696o03tj0}

-   Automatically determine if RLE should be applied.
-   Dictionary encoding for better string compression.
-   Compression (like zstd or snappy) for data.
-   Multiple columns.
-   Push down filtering.
-   Split column data into blocks. Required to implement effective push down filtering.


## API {#API-6ef696o03tj0}


### Encoding {#APIEncoding-w0g696o03tj0}

`encode_column` encodes a `Vec<T>` into Will's Columnar Format. If `use_rle` is
true, then run length encoding will be used.

```rust
pub fn encode_column<Iter, T>(data: Iter, use_rle: bool) -> Vec<u8>
where
    Iter: ExactSizeIterator + Iterator<Item = T>,
    T: 'static + bincode::Encode + Eq,
{
    encode_column_impl(data, use_rle)
}
```


### Decoding {#APIDecoding-npg696o03tj0}

`decode_column` decodes data from a byte stream into an iterator of
`rle::Element<T>`. See [Run Length Encoding](#DataEncodingRunLengthEncoding-0vm696o03tj0).

```rust
pub fn decode_column<T>(r: &'_ mut impl std::io::Read) -> impl '_ + Iterator<Item = rle::Element<T>>
where
    T: 'static + bincode::Decode,
{
    decode_column_impl(r)
}
```


### Optimization Tips {#OptimizationTips-45i696o03tj0}


#### Sorting Data {#OptimizationTipsSortingData-rsi696o03tj0}

If:

-   Order does not matter.
-   There are lots of repeated values.

If the above are true, try sorting and enabling run length encoding. Run length
encoding is efficient at storing data that is heavily repeated. By sorting, the
data will have longer runs of consecutive repeated values. See [Run Length
Encoding](#DataEncodingRunLengthEncoding-0vm696o03tj0) for technical details.


### Tests {#APITests-vfh696o03tj0}

```rust
#[test]
fn test_encoding_prefixed_by_magic_bytes() {
    let data: Vec<i64> = vec![1, 2, 3, 4];
    let encoded_data: Vec<u8> = encode_column(data.into_iter(), false);
    assert_eq!(&encoded_data[0..MAGIC_BYTES_LEN], b"wmedrano0");
}
```

```rust
#[test]
fn test_encode_decode_several() {
    test_can_encode_and_decode_for_type::<i8>([-1, -1]);
    test_can_encode_and_decode_for_type::<u8>([1, 2]);
    test_can_encode_and_decode_for_type::<i16>([-1, 1]);
    test_can_encode_and_decode_for_type::<u16>([1, 2]);
    test_can_encode_and_decode_for_type::<i32>([-1, 1]);
    test_can_encode_and_decode_for_type::<u32>([1, 2]);
    test_can_encode_and_decode_for_type::<i64>([-1, 1]);
    test_can_encode_and_decode_for_type::<u64>([1, 2]);
    test_can_encode_and_decode_for_type::<String>(["a".to_string(), "b".to_string()]);
}
```

```rust
#[test]
fn test_encode_decode_integer() {
    let data: Vec<i64> = vec![-1, 10, 10, 10, 11, 12, 12, 10];
    let encoded_data = encode_column(data.into_iter(), false);
    assert_eq!(
        encoded_data.len(),
        [
            9, // magic_bytes
            1, // u8 header:data_type
            1, // u8 header:use_rle
            1, // varint header:element_count
            1, // varint header:data_size
            8, // data contains 8 elements of varint with size 1.
        ]
        .iter()
        .sum()
    );

    let mut encoded_data_cursor = std::io::Cursor::new(encoded_data);
    assert_equal(
        decode_column::<i64>(&mut encoded_data_cursor),
        [
            rle::Element {
                element: -1,
                run_length: 1,
            },
            rle::Element {
                element: 10,
                run_length: 1,
            },
            rle::Element {
                element: 10,
                run_length: 1,
            },
            rle::Element {
                element: 10,
                run_length: 1,
            },
            rle::Element {
                element: 11,
                run_length: 1,
            },
            rle::Element {
                element: 12,
                run_length: 1,
            },
            rle::Element {
                element: 12,
                run_length: 1,
            },
            rle::Element {
                element: 10,
                run_length: 1,
            },
        ],
    );
}
```

```rust
#[test]
fn test_encode_decode_string() {
    let data: Vec<&'static str> = vec!["foo", "foo", "foo", "bar", "baz", "foo"];
    let encoded_data = encode_column(data.into_iter(), false);
    assert_eq!(
        encoded_data.len(),
        [
            9,  // magic_bytes
            1,  // u8 header:data_type
            1,  // u8 header:use_rle
            1,  // varint header:element_count
            1,  // varint header:data_size
            24, // data contains 8 elements of varint with size 1.
        ]
        .iter()
        .sum()
    );

    let mut encoded_data_cursor = std::io::Cursor::new(encoded_data);
    assert_equal(
        decode_column::<String>(&mut encoded_data_cursor),
        [
            rle::Element {
                element: "foo".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "foo".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "foo".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "bar".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "baz".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "foo".to_string(),
                run_length: 1,
            },
        ],
    );
}
```

```rust
#[test]
fn test_encode_decode_string_with_rle() {
    let data = ["foo", "foo", "foo", "bar", "baz", "foo"];
    let encoded_data = encode_column(data.into_iter(), true);
    assert_eq!(
        encoded_data.len(),
        [
            9, // magic_bytes
            1, // u8 header:data_type
            1, // u8 header:use_rle
            1, // varint header:element_count
            1, // varint header:data_size
            4, // data:element_1:rle_element string "foo" of encoding size 4.
            1, // data:element_1:rle_run_length varint of size 1.
            4, // data:element_2:rle_element string "bar" of encoding size 4.
            1, // data:element_2:rle_run_length varint of size 1.
            4, // data:element_3:rle_element string "baz" of encoding size 4.
            1, // data:element_3:rle_run_length varint of size 1.
            4, // data:element_3:rle_element string "foo" of encoding size 4.
            1, // data:element_3:rle_run_length varint of size 1.
        ]
        .iter()
        .sum()
    );

    let mut encoded_data_cursor = std::io::Cursor::new(encoded_data);
    assert_equal(
        decode_column::<String>(&mut encoded_data_cursor),
        [
            rle::Element {
                element: "foo".to_string(),
                run_length: 3,
            },
            rle::Element {
                element: "bar".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "baz".to_string(),
                run_length: 1,
            },
            rle::Element {
                element: "foo".to_string(),
                run_length: 1,
            },
        ],
    );
}
```


## Format Specification {#FormatSpecification-zfj696o03tj0}


### Format Overview {#FormatSpecificationFormatOverview-j3k696o03tj0}

{{< figure src="/ox-hugo/format-overview.png" >}}

```rust
fn encode_column_impl<T>(
    data: impl ExactSizeIterator + Iterator<Item = T>,
    use_rle: bool,
) -> Vec<u8>
where
    T: 'static + bincode::Encode + Eq,
{
    let elements = data.len();
    let encoded_data = if use_rle {
        encode_data_rle_impl(data.into_iter())
    } else {
        encode_data_base_impl(data.into_iter())
    };
    let header = Header {
        data_type: DataType::from_type::<T>().unwrap(),
        use_rle,
        elements,
        data_size: encoded_data.len(),
    };
    encode_header_and_data(MAGIC_BYTES, header, encoded_data)
}
```


### Magic Bytes {#FormatSpecificationMagicBytes-iyl7tna13tj0}

The magic bytes are 9 bytes long with the contents being "wmedrano0".

```rust
const MAGIC_BYTES: &[u8; MAGIC_BYTES_LEN] = b"wmedrano0";
const MAGIC_BYTES_LEN: usize = 9;
```


### Header {#FormatSpecificationHeader-3tk696o03tj0}

The header contains a Bincode encoded struct:

```rust
#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub struct Header {
    pub data_type: DataType,
    pub use_rle: bool,
    pub elements: usize,
    pub data_size: usize,
}

#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub enum DataType {
    Integer = 0,
    String = 1,
}
```


## Data Encoding {#DataEncoding-sgl696o03tj0}


### Basic Encoding {#DataEncodingBasicEncoding-e4m696o03tj0}

The data consists of a sequence of encoded data. Encoding happens using the Rust
[Bincode](https:github.com/bincode-org/bincode) package to encode/decode each data element.

```rust
fn encode_data_base_impl<T: 'static + bincode::Encode>(data: impl Iterator<Item = T>) -> Vec<u8> {
    let mut encoded = Vec::new();
    for element in data {
        bincode::encode_into_std_write(element, &mut encoded, BINCODE_DATA_CONFIG).unwrap();
    }
    encoded
}
```

```rust
#[test]
fn test_encoding_size() {
    // Small numbers are encoded efficiently.
    assert_eq!(encoded_size(1u8), 1);
    assert_eq!(encoded_size(-1i8), 1);
    assert_eq!(encoded_size(1u64), 1);
    assert_eq!(encoded_size(-1i64), 1);

    // Larger numbers use more bytes with varint encoding. This does not apply
    // to u8 and i8 which do not use varint.
    assert_eq!(encoded_size(255u16), 3);
    assert_eq!(encoded_size(255u8), 1);
    assert_eq!(encoded_size(127i8), 1);
    assert_eq!(encoded_size(-128i8), 1);

    // Derived types (like Structs and Tuples) take up as much space as their subcomponents.
    assert_eq!(encoded_size(1u64), 1);
    assert_eq!(encoded_size(25564), 3);
    assert_eq!(encoded_size((1u64, 255u64)), 4);
    assert_eq!(
        encoded_size(rle::Element {
            element: 1u64,
            run_length: 255
        }),
        4
    );

    // Strings take up string_length + 1.
    assert_eq!(encoded_size("string"), 7);
    assert_eq!(encoded_size(String::from("string")), 7);
    assert_eq!(encoded_size((1u8, String::from("string"))), 8);

    // Fixed sized slices take up space for each of its encoded
    // elements. Variable size slices (or slice references) and vectors take
    // up an additional varint integer of overhead for encoding the length.
    assert_eq!(encoded_size::<&[u8; 3]>(&[1u8, 2, 3]), 3);
    assert_eq!(encoded_size::<[u8; 3]>([1u8, 2, 3]), 3);
    assert_eq!(encoded_size::<&[u8]>(&[1u8, 2, 3]), 4);
    assert_eq!(encoded_size(vec![1u8, 2, 3]), 4);
}
```


### Run Length Encoding {#DataEncodingRunLengthEncoding-0vm696o03tj0}

Run length encoding [[Wikipedia](https://en.wikipedia.org/wiki/Run-length_encoding#:~:text=Run%2Dlength%20encoding%20(RLE),than%20as%20the%20original%20run.)] is a compression technique for repeated values.

TODO: Add visualization.

```rust
#[derive(Encode, Decode, Copy, Clone, PartialEq, Debug)]
pub struct Element<T> {
    // The underlying element.
    pub element: T,
    // Run length is stored as a u64. We could try using a smaller datatype,
    // but Bincode uses "variable length encoding" for integers which is
    // efficient for smaller sizes.
    pub run_length: u64,
}
```

To encode an iterator of type `T` with RLE, it is first converted into an
iterator of type `rle::Element<T>`. It is then used to encode the run length
encoded vector into bytes.

```rust
fn encode_data_rle_impl<T: 'static + bincode::Encode + Eq>(
    data: impl Iterator<Item = T>,
) -> Vec<u8> {
    let rle_data /*: impl Iterator<Item=rle::Element<T>>*/ = rle::encode_iter(data);
    encode_data_base_impl(rle_data)
}
```

```rust
pub fn encode_iter<I>(iter: I) -> impl Iterator<Item = Element<I::Item>>
where
    I: Iterator,
    I::Item: PartialEq,
{
    iter.peekable().batching(|iter| {
        let element = match iter.next() {
            Some(e) => e,
            None => return None,
        };
        let mut run_length = 1;
        while iter.next_if_eq(&element).is_some() {
            run_length += 1;
        }
        Some(Element {
            element,
            run_length,
        })
    })
}
```


#### Tests {#DataEncodingRunLengthEncodingTests-xhn696o03tj0}

```rust
#[test]
fn test_encode_data_without_elements_produces_no_elements() {
    let data: Vec<String> = vec![];
    assert_equal(encode_iter(data.into_iter()), []);
}

#[test]
fn test_encode_data_combines_repeated_elements() {
    let data = [
        "repeated-3",
        "repeated-3",
        "repeated-3",
        "no-repeat",
        "repeated-2",
        "repeated-2",
        "repeated-3",
        "repeated-3",
        "repeated-3",
    ];
    assert_equal(
        encode_iter(data.into_iter()),
        [
            Element {
                run_length: 3,
                element: "repeated-3",
            },
            Element {
                run_length: 1,
                element: "no-repeat",
            },
            Element {
                run_length: 2,
                element: "repeated-2",
            },
            Element {
                run_length: 3,
                element: "repeated-3",
            },
        ],
    );
}
```


## Source Code {#SourceCode-45o696o03tj0}

The source code is stored at
<https://github.com/wmedrano/wills-columnar-format>. The main source file is
`wills-columnar-format.org` which is used to generate the Rust source files like
`src/lib.rs`.

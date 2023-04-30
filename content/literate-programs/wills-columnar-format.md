+++
title = "Will's Columnar Format"
author = ["Will Medrano"]
date = 2023-04-23
lastmod = 2023-04-30T16:48:08-07:00
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
`wills-columnar-format.org` within Emacs.

Building and testing relies on Cargo.

```shell
cargo build
cargo test
cargo test $FN_TO_TEST
```


#### Emacs Utility Blocks {#IntroductionBuildingandTestingLibraryEmacsUtilityBlocks-l6zkn7714tj0}

The following code snippets may be evaluated with `C-c C-c`.

```emacs-lisp
;; Execute blocks in this file without asking for confirmation.
(setq-local org-confirm-babel-evaluate nil)
```

```emacs-lisp
;; Export the org file as a Hugo markdown post.
(add-hook 'after-save-hook #'org-hugo-export-to-md 0 t)
```

```emacs-lisp
;; Automatically regenerate Rust code after editing this file.
(add-hook 'after-save-hook #'org-babel-tangle 0 t)
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

Supports:

-   Only a single column per encode/decode.
-   Integer (both signed and unsigned) and String types.
-   Run length encoding.


#### V1 Features - WIP {#FeaturesV1FeaturesWIP-6uaickf05tj0}

-   Efficient row skipping.
-   Multiple pages per column, required for efficient row skipping.
-   Benchmarking suite.


#### Tentative V2 Features {#FeaturesTentativeV1Features-ppe696o03tj0}

-   Support multiple columns.
-   Automatically determine if RLE should be applied.
-   Dictionary encoding for better string compression.
-   Compression (like zstd or snappy) for data.


## API {#API-6ef696o03tj0}


### Encoding {#APIEncoding-w0g696o03tj0}

`encode_column` encodes an iterator over items into Will's Columnar Format. If
`use_rle` is true, then run length encoding will be used.

```rust
pub fn encode_column<Iter, T, W>(data: Iter, w: &mut W, use_rle: bool) -> Result<Footer>
where
    Iter: Iterator<Item = T>,
    T: 'static + bincode::Encode + Eq,
    W: Write,
{
    encode::encode_column_impl(w, data, use_rle)
}
```


### Decoding {#APIDecoding-npg696o03tj0}

`decode_column` decodes data from a byte stream into an iterator of
`Result<rle::Values<T>>`. See [Run Length Encoding](#DataEncodingRunLengthEncoding-0vm696o03tj0).

```rust
pub fn decode_column<'a, T>(
    r: impl 'a + Read + Seek,
) -> Result<impl 'a + Iterator<Item = Result<rle::Values<T>>>>
where
    T: 'static + bincode::Decode,
{
    decode::decode_column_impl(r)
}

pub fn decode_footer(r: impl Read + Seek) -> Result<Footer> {
    let mut r = r;
    decode::decode_footer_impl(&mut r)
}
```


### Optimization Tips {#OptimizationTips-45i696o03tj0}


#### RLE {#APIOptimizationTipsRLE-0w1ln7714tj0}

Run length encoding is used to compress data that is heavily repeated. If data
does not repeat, then it is strictly worse.

Example where run length encoding yields benefits:

{{< figure src="/ox-hugo/wills-columnar-format/rle-good-example.png" >}}

In the worst case when there are no runs, RLE is actually worse. In the example
below, notice how both normal and run length encoding have the same number of
values. run length encoding is actually strictly worse since it has to encode
the value **and** the run length.

{{< figure src="/ox-hugo/wills-columnar-format/rle-bad-example.png" >}}


#### Sorting Data {#OptimizationTipsSortingData-rsi696o03tj0}

-   Order does not matter.
-   There are lots of repeated values.

If the above are true, try sorting and enabling run length encoding. Run length
encoding is efficient at storing data that is heavily repeated. By sorting, the
data will have longer runs of consecutive repeated values. See [Run Length
Encoding](#DataEncodingRunLengthEncoding-0vm696o03tj0) for technical details.


### Tests {#APITests-vfh696o03tj0}

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
    let mut encoded_data = Vec::new();
    encode_column(data.into_iter(), &mut encoded_data, false).unwrap();
    assert_eq!(
        encoded_data.len(),
        [
            8, // data contains 8 values of varint with size 1.
            1, // u8 footer:data_type
            1, // u8 footer:use_rle
            1, // varint footer:pages_count
            1, // varint footer:page1:file_offset
            1, // varint footer:page1:values_count
            1, // varint footer:page1:encoded_values_count
            8, // u64 footer_size
        ]
        .iter()
        .sum()
    );

    let mut encoded_data_cursor = Cursor::new(encoded_data);
    assert_equal(
        decode_column::<i64>(&mut encoded_data_cursor)
            .unwrap()
            .map(Result::unwrap),
        [
            rle::Values {
                value: -1,
                run_length: 1,
            },
            rle::Values {
                value: 10,
                run_length: 1,
            },
            rle::Values {
                value: 10,
                run_length: 1,
            },
            rle::Values {
                value: 10,
                run_length: 1,
            },
            rle::Values {
                value: 11,
                run_length: 1,
            },
            rle::Values {
                value: 12,
                run_length: 1,
            },
            rle::Values {
                value: 12,
                run_length: 1,
            },
            rle::Values {
                value: 10,
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
    let mut encoded_data = Vec::new();
    encode_column(data.into_iter(), &mut encoded_data, false).unwrap();
    assert_eq!(
        encoded_data.len(),
        [
            24, // data contains 6 values of varint with size 4.
            1,  // u8 footer:data_type
            1,  // u8 footer:use_rle
            1,  // varint footer:pages_count
            1,  // varint footer:page1:file_offset
            1,  // varint footer:page1:values_count
            1,  // varint footer:page1:encoded_values_count
            8,  // u64 footer_size
        ]
        .iter()
        .sum()
    );

    let mut encoded_data_cursor = Cursor::new(encoded_data);
    assert_equal(
        decode_column::<String>(&mut encoded_data_cursor)
            .unwrap()
            .map(Result::unwrap),
        [
            rle::Values {
                value: "foo".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "foo".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "foo".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "bar".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "baz".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "foo".to_string(),
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
    let mut encoded_data = Vec::new();
    let footer = encode_column(data.into_iter(), &mut encoded_data, true).unwrap();
    assert_eq!(
        encoded_data.len(),
        [
            4, // page1:element1:rle_element string "foo" of encoding size 4.
            1, // page1:element1:rle_run_length varint of size 1.
            4, // page1:element2:rle_element string "bar" of encoding size 4.
            1, // page1:element2:rle_run_length varint of size 1.
            4, // page1:element3:rle_element string "baz" of encoding size 4.
            1, // page1:element3:rle_run_length varint of size 1.
            4, // page1:element3:rle_element string "foo" of encoding size 4.
            1, // page1:element3:rle_run_length varint of size 1.
            1, // u8 footer:data_type
            1, // u8 footer:use_rle
            1, // varint footer:pages_count
            1, // varint footer:page1:file_offset
            1, // varint footer:page1:values_count
            1, // varint footer:page1:encoded_values_count
            8, // u64 footer_size
        ]
        .iter()
        .sum(),
        "{:?}",
        footer
    );

    let mut encoded_data_cursor = Cursor::new(encoded_data);
    assert_equal(
        decode_column::<String>(&mut encoded_data_cursor)
            .unwrap()
            .map(Result::unwrap),
        [
            rle::Values {
                value: "foo".to_string(),
                run_length: 3,
            },
            rle::Values {
                value: "bar".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "baz".to_string(),
                run_length: 1,
            },
            rle::Values {
                value: "foo".to_string(),
                run_length: 1,
            },
        ],
    );
}
```

```rust
#[test]
fn encode_on_many_values_outputs_several_pages() {
    let values = std::iter::repeat(-1i64).take(1_000_000);
    let mut encoded_data = Vec::new();
    let footer = encode_column(values, &mut encoded_data, false).unwrap();
    assert!(footer.pages.len() > 1, "{:?}", footer);
    assert_eq!(decode_footer(Cursor::new(&encoded_data)).unwrap(), footer);
    assert_equal(
        decode_column::<i64>(Cursor::new(&encoded_data))
            .unwrap()
            .map(Result::unwrap),
        std::iter::repeat(rle::Values::single(-1i64)).take(1_000_000),
    );
}
```

```rust
#[test]
fn decode_on_wrong_data_type_fails() {
    // SignedInteger.
    let values = std::iter::once(-1i64);
    let mut encoded_data = Vec::new();
    encode_column(values, &mut encoded_data, false).unwrap();

    assert!(decode_column::<u64>(Cursor::new(&encoded_data)).is_err());
    assert!(decode_column::<String>(Cursor::new(&encoded_data)).is_err());
    assert!(decode_column::<i8>(Cursor::new(&encoded_data)).is_err());
    assert!(decode_column::<u8>(Cursor::new(&encoded_data)).is_err());
}
```


## <span class="org-todo todo TODO">TODO</span> Benchmarks {#Benchmarks-32c8xx41atj0}

Perhaps look to [Wes McKinney's](https://ursalabs.org/blog/2019-10-columnar-perf/) columnar file performance write-up for inspiration.


## Format Specification {#FormatSpecification-zfj696o03tj0}


### Format Overview {#FormatSpecificationFormatOverview-j3k696o03tj0}

{{< figure src="/ox-hugo/wills-columnar-format/format-diagram.png" >}}

```rust
pub fn encode_column_impl<T>(
    w: &mut impl Write,
    values_iter: impl Iterator<Item = T>,
    use_rle: bool,
) -> Result<Footer>
where
    T: 'static + bincode::Encode + Eq,
{
    // TODO: Return an error.
    let data_type = DataType::from_type::<T>().expect("unsupported data type");
    let mut values_iter = values_iter;

    let mut pages = Vec::new();
    let mut file_offset = 0;
    loop {
        let encoding =
            encode_values_as_bincode(&mut values_iter, file_offset, MIN_TARGET_PAGE_SIZE, use_rle)?;
        if encoding.encoded_values.is_empty() {
            break;
        } else {
            file_offset += w.write(encoding.encoded_values.as_slice())? as i64;
            pages.push(encoding.page_info);
        }
    }
    let footer = Footer {
        data_type,
        use_rle,
        pages,
    };
    let footer_size = bincode::encode_into_std_write(&footer, w, BINCODE_DATA_CONFIG)? as u64;
    w.write(&footer_size.to_le_bytes())?;
    Ok(footer)
}
```


### Pages {#FormatSpecificationPages-b9u4ccg05tj0}

Pages contain actual data for the column. Each page encodes elements using
Bincode. The number of elements within the page are stored in the footer.

{{< figure src="/ox-hugo/wills-columnar-format/format-diagram-pages.png" >}}

The size of each page is currently not configurable. However, the encoder aims
for a particular minimum page sizes.

```rust
const MIN_TARGET_PAGE_SIZE: usize = 2048;
```


### File Footer {#FormatSpecificationFileFooter-nn404df05tj0}

The footer contains information about the columns like the data type, if run
length encoding is enabled and information for each page. The details for pages
are:

-   **file_offset** - Where the page starts relative to position 0 in the file.
-   **values_count** - The number of values stored within the page. This is the
    sum of all the run_lengths for run length encoded columns. For example, the
    string `"foo"` repeated 10 times will count as 10 elements.
-   **encoded values count** - The number of values that were encoded. This does not
    take into account run length. For example, if `"foo"` is repeated 10 times and
    run length encoding is used, then **encoded values count** will be `1`. However,
    if run length encoding is not used, then this will be `10`.

{{< figure src="/ox-hugo/wills-columnar-format/format-diagram-footer.png" >}}

```rust
#[derive(Encode, Decode, PartialEq, Eq, Clone, Debug)]
pub struct Footer {
    pub data_type: DataType,
    pub use_rle: bool,
    pub pages: Vec<PageInfo>,
}

#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub enum DataType {
    UnsignedByte = 0,
    SignedByte = 1,
    UnsignedInteger = 2,
    SignedInteger = 3,
    String = 4,
}

#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub struct PageInfo {
    pub file_offset: i64,
    pub values_count: usize,
    pub encoded_values_count: usize,
}
```


## Data Encoding {#DataEncoding-sgl696o03tj0}


### Basic Encoding {#DataEncodingBasicEncoding-e4m696o03tj0}

The data consists of a sequence of encoded data. Encoding happens using the Rust
[Bincode](https:github.com/bincode-org/bincode) package to encode/decode each data element.

{{< figure src="/ox-hugo/wills-columnar-format/basic-encoding.png" >}}

```rust
struct Encoding {
    pub encoded_values: Vec<u8>,
    pub page_info: PageInfo,
}

fn encode_values_as_bincode<T: 'static + bincode::Encode>(
    values: &mut impl Iterator<Item = T>,
    file_offset: i64,
    target_encoded_size: usize,
    use_rle: bool,
) -> Result<Encoding>
where
    T: 'static + bincode::Encode + Eq,
{
    let mut encoded_values = Vec::new();
    if use_rle {
        let mut values_count = 0;
        let mut encoded_values_count = 0;
        for rle in rle::encode_iter(values) {
            values_count += rle.run_length as usize;
            encoded_values_count += 1;
            bincode::encode_into_std_write(rle, &mut encoded_values, BINCODE_DATA_CONFIG)?;
            if encoded_values.len() >= target_encoded_size {
                break;
            }
        }
        Ok(Encoding {
            encoded_values,
            page_info: PageInfo {
                file_offset,
                values_count,
                encoded_values_count,
            },
        })
    } else {
        let mut values_count = 0;
        for value in values {
            values_count += 1;
            bincode::encode_into_std_write(value, &mut encoded_values, BINCODE_DATA_CONFIG)?;
            if encoded_values.len() >= target_encoded_size {
                break;
            }
        }
        Ok(Encoding {
            encoded_values,
            page_info: PageInfo {
                file_offset,
                values_count,
                encoded_values_count: values_count,
            },
        })
    }
}
```


#### Tests {#DataEncodingBasicEncodingTests-sfz7wx714tj0}

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
        encoded_size(rle::Values {
            value: 1u64,
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

Run length encoding [[Wikipedia](https://en.wikipedia.org/wiki/Run-length_encoding#:~:text=Run%2Dlength%20encoding%20(RLE),than%20as%20the%20original%20run.)] is a compression technique for repeated
values. For RLE encoding, instead of storing each element, we store a
tuple. `(element, run_length)` where `element` contains the data and the
`run_length` stores how many times the value is repeated. The most surefire way
to determine if RLE has benefits is to test it in practice. That is to say, try
using both RLE and no RLE to see which one has the smaller size.

{{< figure src="/ox-hugo/wills-columnar-format/rle-encoding.png" >}}

```rust
#[derive(Encode, Decode, Copy, Clone, PartialEq, Debug)]
pub struct Values<T> {
    // The underlying element.
    pub value: T,
    // Run length is stored as a u64. We could try using a smaller datatype,
    // but Bincode uses "variable length encoding" for integers which is
    // efficient for smaller sizes.
    pub run_length: u64,
}

impl<T> Values<T> {
    pub fn single(element: T) -> Self {
        Values {
            value: element,
            run_length: 1,
        }
    }
}
```

To encode an iterator of type `T` with RLE, it is first converted into an
iterator of type `rle::Values<T>`. It is then used to encode the run length
encoded vector into bytes.

```rust
pub fn encode_iter<'a, T: 'a + bincode::Encode + Eq>(
    data: impl 'a + Iterator<Item = T>,
) -> impl 'a + Iterator<Item = Values<T>> {
    data.peekable().batching(move |iter| -> Option<Values<T>> {
        let element = iter.next()?;
        let mut run_length = 1;
        while iter.next_if_eq(&element).is_some() {
            run_length += 1;
        }
        Some(Values {
            value: element,
            run_length,
        })
    })
}
```

To decode a single `rle::Values` into multiple, the value is repeated a number
of times equal to `run_length`.

```rust
impl<T> Values<T> {
    pub fn repeated(&self) -> impl '_ + Iterator<Item = &'_ T> {
        std::iter::repeat(&self.value).take(self.run_length as usize)
    }
}
```

Note that decoding is not always required. Sometimes it is more optimal to deal
directly with `rle::Values`. Take the following example:

```rust
#[test]
fn test_repeated_sum_equal_to_multiplication() {
    let rle_values = Values {
        value: 3u64,
        run_length: 5,
    };
    // Technically valid.
    assert_eq!(rle_values.repeated().sum::<u64>(), 15,);
    // More efficient.
    assert_eq!(rle_values.value * rle_values.run_length, 15);
}
```


#### Tests {#DataEncodingRunLengthEncodingTests-xhn696o03tj0}

```rust
#[test]
fn test_encode_data_without_values_produces_no_values() {
    let data: Vec<String> = vec![];
    assert_equal(encode_iter(data.into_iter()), []);
}

#[test]
fn test_encode_data_combines_repeated_values() {
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
            Values {
                run_length: 3,
                value: "repeated-3",
            },
            Values {
                run_length: 1,
                value: "no-repeat",
            },
            Values {
                run_length: 2,
                value: "repeated-2",
            },
            Values {
                run_length: 3,
                value: "repeated-3",
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

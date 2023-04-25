+++
author = ["Will Medrano"]
lastmod = 2023-04-25T10:15:44-07:00
draft = false
+++

// [Dependencies:3]({{< relref "wills-columnar-format#IntroductionCargotoml-cqc696o03tj0" >}})
pub mod rle;

\#[cfg(test)]
mod test_bincode;
\#[cfg(test)]
mod test_lib;
\#[cfg(test)]
mod test_rle;

use bincode::{Decode, Encode};
use itertools::Either;
use std::{any::TypeId, io::Read, marker::PhantomData};
// Dependencies:3 ends here

// [Encoding:1]({{< relref "wills-columnar-format#APIEncoding-w0g696o03tj0" >}})
pub fn encode_column&lt;Iter, T&gt;(data: Iter, use_rle: bool) -&gt; Vec&lt;u8&gt;
where
    Iter: ExactSizeIterator + Iterator&lt;Item = T&gt;,
    T: 'static + bincode::Encode + Eq,
{
    encode_column_impl(data, use_rle)
}
// Encoding:1 ends here

// [Decoding:1]({{< relref "wills-columnar-format#APIDecoding-npg696o03tj0" >}})
pub fn decode_column&lt;T&gt;(r: &amp;'\_ mut impl std::io::Read) -&gt; impl '\_ + Iterator&lt;Item = rle::Element&lt;T&gt;&gt;
where
    T: 'static + bincode::Decode,
{
    decode_column_impl(r)
}
// Decoding:1 ends here

// [Format Overview:2]({{< relref "wills-columnar-format#FormatSpecificationFormatOverview-j3k696o03tj0" >}})
fn encode_column_impl&lt;T&gt;(
    data: impl ExactSizeIterator + Iterator&lt;Item = T&gt;,
    use_rle: bool,
) -&gt; Vec&lt;u8&gt;
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
        data_type: DataType::from_type::&lt;T&gt;().unwrap(),
        use_rle,
        elements,
        data_size: encoded_data.len(),
    };
    encode_header_and_data(MAGIC_BYTES, header, encoded_data)
}
// Format Overview:2 ends here

// [Format Overview:3]({{< relref "wills-columnar-format#FormatSpecificationFormatOverview-j3k696o03tj0" >}})
const BINCODE_DATA_CONFIG: bincode::config::Configuration = bincode::config::standard();

fn encode_header_and_data(
    magic_bytes: &amp;'static [u8],
    header: Header,
    encoded_data: Vec&lt;u8&gt;,
) -&gt; Vec&lt;u8&gt; {
    assert_eq!(header.data_size, encoded_data.len());
    Vec::from_iter(
        magic_bytes
            .iter()
            .copied()
            .chain(header.encode())
            .chain(encoded_data.iter().copied()),
    )
}

fn decode_column_impl&lt;T: 'static + bincode::Decode&gt;(
    r: &amp;'\_ mut impl std::io::Read,
) -&gt; impl '\_ + Iterator&lt;Item = rle::Element&lt;T&gt;&gt; {
    let mut magic_string = [0u8; MAGIC_BYTES_LEN];
    r.read_exact(&amp;mut magic_string).unwrap();
    assert_eq!(
        &amp;magic_string, MAGIC_BYTES,
        "Expected magic string {:?}.",
        MAGIC_BYTES
    );
    let header = Header::decode(r);
    assert!(
        header.data_type.is_supported::&lt;T&gt;(),
        "Format of expected type {:?} does not support {:?}.",
        header.data_type,
        std::any::type_name::&lt;T&gt;(),
    );
    if header.use_rle {
        let rle_elements _**: impl Iterator&lt;Item=Element&lt;T&gt;&gt;**_ = decode_rle_data(header.elements, r);
        Either::Left(rle_elements)
    } else {
        let elements: DataDecoder&lt;T, \_&gt; = DataDecoder::new(header.elements, r);
        let rle_elements = elements.map(|element| rle::Element {
            element,
            run_length: 1,
        });
        Either::Right(rle_elements)
    }
}
// Format Overview:3 ends here

// [Magic Bytes:1]({{< relref "wills-columnar-format#FormatSpecificationMagicBytes-iyl7tna13tj0" >}})
const MAGIC_BYTES: &amp;[u8; MAGIC_BYTES_LEN] = b"wmedrano0";
const MAGIC_BYTES_LEN: usize = 9;
// Magic Bytes:1 ends here

// [Header:1]({{< relref "wills-columnar-format#FormatSpecificationHeader-3tk696o03tj0" >}})
impl Header {
    const CONFIGURATION: bincode::config::Configuration = bincode::config::standard();
}

impl DataType {
    const ALL_DATA_TYPE: [DataType; 2] = [DataType::Integer, DataType::String];

fn from_type&lt;T: 'static&gt;() -&gt; Option&lt;DataType&gt; {
    DataType::ALL_DATA_TYPE
        .into_iter()
        .find(|dt| dt.is_supported::&lt;T&gt;())
}

    fn is_supported&lt;T: 'static&gt;(&amp;self) -&gt; bool {
        let type_id = TypeId::of::&lt;T&gt;();
        match self {
            DataType::Integer =&gt; [
                TypeId::of::&lt;i8&gt;(),
                TypeId::of::&lt;u8&gt;(),
                TypeId::of::&lt;i16&gt;(),
                TypeId::of::&lt;u16&gt;(),
                TypeId::of::&lt;i32&gt;(),
                TypeId::of::&lt;u32&gt;(),
                TypeId::of::&lt;i64&gt;(),
                TypeId::of::&lt;u64&gt;(),
            ]
            .contains(&amp;type_id),
            DataType::String =&gt; {
                [TypeId::of::&lt;String&gt;(), TypeId::of::&lt;&amp;'static str&gt;()].contains(&amp;type_id)
            }
        }
    }
}

impl Header {
    fn encode(&amp;self) -&gt; Vec&lt;u8&gt; {
        bincode::encode_to_vec(self, Self::CONFIGURATION).unwrap()
    }

    fn decode(r: &amp;mut impl std::io::Read) -&gt; Header {
        bincode::decode_from_std_read(r, Self::CONFIGURATION).unwrap()
    }
}
// Header:1 ends here

// [Header:2]({{< relref "wills-columnar-format#FormatSpecificationHeader-3tk696o03tj0" >}})
\#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub struct Header {
    pub data_type: DataType,
    pub use_rle: bool,
    pub elements: usize,
    pub data_size: usize,
}

\#[derive(Encode, Decode, PartialEq, Eq, Copy, Clone, Debug)]
pub enum DataType {
    Integer = 0,
    String = 1,
}
// Header:2 ends here

// [Basic Encoding:1]({{< relref "wills-columnar-format#DataEncodingBasicEncoding-e4m696o03tj0" >}})
fn encode_data_base_impl&lt;T: 'static + bincode::Encode&gt;(data: impl Iterator&lt;Item = T&gt;) -&gt; Vec&lt;u8&gt; {
    let mut encoded = Vec::new();
    for element in data {
        bincode::encode_into_std_write(element, &amp;mut encoded, BINCODE_DATA_CONFIG).unwrap();
    }
    encoded
}
// Basic Encoding:1 ends here

// [Run Length Encoding:2]({{< relref "wills-columnar-format#DataEncodingRunLengthEncoding-0vm696o03tj0" >}})
fn encode_data_rle_impl&lt;T: 'static + bincode::Encode + Eq&gt;(
    data: impl Iterator&lt;Item = T&gt;,
) -&gt; Vec&lt;u8&gt; {
    let rle_data _**: impl Iterator&lt;Item=rle::Element&lt;T&gt;&gt;**_ = rle::encode_iter(data);
    encode_data_base_impl(rle_data)
}
// Run Length Encoding:2 ends here

// [Run Length Encoding:3]({{< relref "wills-columnar-format#DataEncodingRunLengthEncoding-0vm696o03tj0" >}})
fn decode_rle_data&lt;T: 'static + bincode::Decode&gt;(
    elements: usize,
    r: &amp;'\_ mut impl Read,
) -&gt; impl '\_ + Iterator&lt;Item = rle::Element&lt;T&gt;&gt; {
    let mut elements = elements;
    std::iter::from_fn(move || {
        if elements == 0 {
            return None;
        }
        let rle_element: rle::Element&lt;T&gt; =
            bincode::decode_from_std_read(r, BINCODE_DATA_CONFIG).unwrap();
        assert!(
            rle_element.run_length as usize &lt;= elements,
            "{} &lt;= {}",
            elements,
            rle_element.run_length
        );
        elements -= rle_element.run_length as usize;
        Some(rle_element)
    })
}

struct DataDecoder&lt;T, R&gt; {
    reader: R,
    element_count: usize,
    element_type: PhantomData&lt;T&gt;,
}

impl&lt;T, R&gt; DataDecoder&lt;T, R&gt; {
    pub fn new(element_count: usize, reader: R) -&gt; DataDecoder&lt;T, R&gt; {
        DataDecoder {
            reader,
            element_count,
            element_type: PhantomData,
        }
    }
}

impl&lt;T, R&gt; Iterator for DataDecoder&lt;T, R&gt;
where
    T: bincode::Decode,
    R: Read,
{
    type Item = T;

    fn next(&amp;mut self) -&gt; Option&lt;T&gt; {
        if self.element_count == 0 {
            return None;
        }
        self.element_count -= 1;
        let element: T =
            bincode::decode_from_std_read(&amp;mut self.reader, BINCODE_DATA_CONFIG).unwrap();
        Some(element)
    }
}
// Run Length Encoding:3 ends here

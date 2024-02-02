+++
title = "Bats Devlog 1"
author = ["Will Medrano"]
date = 2023-12-08
tags = ["rust", "music", "bats", "devlog"]
draft = false
+++

## Bats Devlog 1 {#Bats-0oy5ecc1h1k0}

Previous: [Devlog 0](https://www.wmedrano.dev/posts/introducing-bats/)

Repo: <https://gitlab.com/wmedrano/bats>


### Introduction {#BatsDevlog1Introduction-z5n65g00i1k0}

The main features that were implemented in November were new UI improvements and support for sequencing, saving, and loading. The project also moved to [gitlab.com/wmedrano/bats](https://gitlab.com/wmedrano/bat) with lots of CI/CD integrations. Overall I'm happy with the implementation of the features and new dev environment but dissapointed with the UI/UX.

New sequencer features:

-   Ticking metronome with settable BPM.
-   Sequencer with playback on/off, recording on/off. Currently fixed at measures with 4 beats per measure.
-   Can clear sequence per track.

New project features:

-   Saving and loading implemented.

New plugin features:

-   Toof has velocity sensitivity.
-   Toof uses exponential envelopes for a slightly more musical sound. Still needs some tweaking.

New non functionaly requirements:

-   Repo moved to [gitlab.com/wmedrano/bats](https://gitlab.com/wmedrano/bat).
-   GitLab CI/CD pipelines for building, linting, testing, code coverage, and benchmarks.
-   GitLab CI/CD pipelines run on custom docker image to improve speed.


### New Features {#BatsDevlog1NewFeatures-w16b2i10i1k0}


#### Sequencer {#BatsDevlog1NewFeaturesSequencer-asw54z10i1k0}

{{< figure src="/ox-hugo/wmedrano-dev/bats-devlog-1-sequencer.png" >}}

The major new feature this month is sequencing. The implementation for the backend and the API for the frontend is pretty solid. However, the UI/UX for using it is very clunky. I don't have any plans to address this anytime soon since I'll likely reimplement the UI entirely at some point.

Implementing the sequencer involved storing data. Previously, the midi input would be mapped directly to the midi output. For sequencing, `MidiEvent` was introduced. This stores a Midi Message and the musical position (like beat and sub beat) it occurs in. Every frame that is being processed is assigned a `Position` range.

{{< figure src="/ox-hugo/wmedrano-dev/bats-devlog-1-sequences-dot.png" >}}


#### Saving and Loading {#BatsDevlog1NewFeaturesSavingandLoading-5b264z10i1k0}

Saving and loading are also implemented. There was no urgency for this as Bats is not completely usable for an end-to-end music project yet, but it was relatevily easy to implement and reminds me to keep my objects serializable. The initial implementation used Serde to just serialize the active bats object and save/load it. This had 2 problems:

-   The size was rather large as several intermediary buffers were stored.
-   Did not support saving and loading with different buffer sizes or sample rates.

To remedy this, the main `Bats` object got a `BatsBuilder` object. These can readily be converted to and from each other. The `BatsBuilder` object doesn't have the preallocated intermediary buffers and does not depend on the sample rate. These 2 parameters are required when converting from `BatsBuilder` to `Bats`. The save format is the Serde compatible `BatsBuilder` object using the [Postcard](https://github.com/jamesmunns/postcard) library.

One small challenge with serializing was that Bat's midi encoding library does not support Serde. I took this opportunity to fork [wmidi](https://github.com/rustaudio/wmidi) and add Serde support and drop `SysEx` support. Dropping SysEx allowed the `MidiMessage` to implement the `Copy` trait which showed measureable performance improvements in the benchmarks. The fork is called `bmidi` and is within the `Bats` repo.


#### GitLab {#BatsDevlog1GitLab-b88b2i10i1k0}

Bats switched over to GitLab. There was no real reason besides trying out GitLab (again). Compared to GitHub, I noticed a few changes. For the review, see my [Trying GitLab](https://www.wmedrano.dev/posts/trying-gitlab) post. I will continue to use GitLab for Bats, but may switch back to GitHub if I start picking up users as GitHub has a bigger open source community.


### Future {#BatsDevlog1Future-2pu6rx60i1k0}

November saw the big launch of sequencing in Bats. However, I will be taking December very easy. Between working and Bats and my full-time job, I am getting pretty exhausted and close to burnout. I hope to recover in January and hopefully make more progress on Bats. The main things that should be coming to Bats eventually are:

-   [minor] Improve `Plugin` trait to make plugins easier.
-   [minor] Improve quality of Toof plugin. Possibly drop support for Polyphony to give it more of an identity.
-   [minor] Introduce a new (FM?) plugin.
-   [major] Introduce sampling and a sampler plugin.
-   [major] Rehaul the UI.

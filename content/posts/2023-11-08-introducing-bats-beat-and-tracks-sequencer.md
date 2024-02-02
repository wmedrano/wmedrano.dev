+++
title = "Introducing Bats: Beat And Tracks Sequencer"
author = ["Will Medrano"]
date = 2023-11-08
tags = ["rust", "music", "bats", "devlog"]
draft = false
+++

## Bats {#Bats-tf26ad70i1k0}


### Introduction {#BatsIntroduction-pa56ad70i1k0}

Bats is a BEATS AND TRACKS SEQUENCER similar to Maschine and the Teenage Engineering OP-1. Tentatively, the MVP should eventually have the following features:

-   A usable synthesizer plugin that can produce decent bass sounds.
-   Sampler that can produce sounds.
-   Essential effets like filters and compressors, with a possible addition of a reverb plugin effect as a stretch goal.
-   MIDI recording for sequencing tracks.
-   Performance suitable to run on small devices like the Raspebrry Pi 4.

The main motivation is to create a small groovebox that meets my sampling needs in a small form factor. Not to mention, creating and programming something cool.

The BATS source code can be found on [[GitHub]​](https://github.com/wmedrano/bats).


### Inspiration {#BatsInspiration-i086ad70i1k0}

Every once in a while I take up making a "DAW". Like most other personal projects, I've dropped the project each time due to lack of motivation, progress, time, and stress. So I am once again embarking on this quest. The most recent points of inspiration are:

-   My slight dissapointment in my newly purchased `Teenage Engineering OP-1`.
-   The controversial statement "open Source Software doesn't do anything creative".


#### Teenage Engineering OP-1 {#BatsInspirationTeenageEngineeringOP1-uja6ad70i1k0}

{{< figure src="/ox-hugo/wmedrano-dev/op-1.jpg" >}}

I recently purchased an OP-1. My main motivation for this impulse buy: avoiding Windows. My current preferred music production maschine is Maschine. I have preffered using Maschine over the MPC live, Ableton Live, and Elektron Digitakt. However, Maschine requires that I use Windows instead of sticking to my preferred Linux setups. Since gaming on Linux has improved, there has been even less reason to stick to Windows. So with this information, instead of getting the standalone Maschine Plus, I purchased the OP-1.

The OP-1 is a great piece of gear for sure, but I found it lacking in the sampling department. Its a lot of work to get samples into the machine and is still plenty of work to chop them up properly. If the sampling workflow were better, then the OP-1 would be the perfect device for me.


#### Don't Be Original {#BatsInspirationDontBeOriginal-4fd6ad70i1k0}

There was a rant that I heard that open source software isn't original. The claim isn't worth humoring too much, but it did get me thinking about how this appies to the music space. Specifically:

1.  The OP-1 is great, but I would like some small tweaks.
2.  The limited feature set of the OP-1 is achievable. I can code something with similar functionality, though style is a different issue.
3.  I DON'T need to be original. I know what I like about OP-1/Maschine/Ableton/MPC/Digitakt, theres no shame in borrowing the great ideas. Executing is the most important part after all.


### Expected Challenges {#BatsExpectedChallenges-r4g6ad70i1k0}

I'm off to the races now to build myself a groovebox. The limited feature set should help me keep focus but the following may still be challenging:

-   Sequencer - I haven't made a sequencer before. I also haven't used an "intuitive" sequencer that can track a whole song. Explaining how sequencers work to beginners has always been a headache to me. I've also never personally enjoyed learning the sequencing mechanisms, I just want to get straight to looping, recording, and iterating.
-   Sampler - This is a big piece. Supporting recording, chopping, effects, and pitch shifting are a big task I don't have much experience in.
-   UX - Not much to be said here. The above items are hard, but making them with good UX is even harder. It would be good if I can use my own product successfully, but even better if others can adapt quickly to BATS.

These are the 3 items I expect to be the most challenging to execute. The risk of other things such as performance, plugin selection, and gui are a much lower risk.


## Current Progress {#CurrentProgress-rmi6ad70i1k0}

After a month of working on this in my spare time, I have made:

-   Automated unit testing, profiling, and benchmaking.
-   Midi input and audio output on Linux.
-   A simple terminal UI navigated with arrow keys, enter, and escape.
-   Support for 8 tracks.
-   The "toof" plugin. A Sawtooth wave with a Moog Filter. Can produce decent basslines!

{{< figure src="/ox-hugo/wmedrano-dev/introducing-bats-1.jpg" >}}

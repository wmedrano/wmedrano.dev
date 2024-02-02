+++
title = "Bats Devlog 2"
author = ["Will Medrano"]
date = 2024-01-14
tags = ["rust", "music", "bats", "devlog"]
draft = false
+++

## Bats Devlog 2 {#Bats-0oy5ecc1h1k0}

Previous: [Devlog 1](https://www.wmedrano.dev/posts/bats-devlog-1)

Repo: <https://gitlab.com/wmedrano/bats>


### Introduction {#BatsDevlog2Introduction-sqq3j0i0r2k0}

Since Devlog 1, not much has changed on Bats. I previously
accomplished a milestone where Bats could record and playback, but I
was dissapointed with the whole UX. To avoid burnout, I didn't spend
much time thinking about Bats. I spent half the time doing simple
features and cleanups and the other working on something else entirely
(a Guile Scheme based text editor).

The following updates landed since Devlog 1:

-   Toof plugin became monophonic instead of polyphonic, but the filter
    can now be modulated by an envelope.
-   Added square and triangle waves.
-   Playing back the loop can be enabled or disabled.
-   Save format was changed from the postcard binary format to
    JSON. This allows the save files to be human readable.
-   Plugin trait now supports having an associated \`Param\` type
    parameter. Prior to this, plugin's would have to manually keep track
    of integer IDs when implementing the \`set_param\` and \`get_param\`
    methods.
-   More unit tests and some code cleanups.
-   [In Progress] - Clean up the UX.


### Updates {#BatsDevlog2Updates-zxrcm7j0r2k0}


#### Toof Plugin Became Monophonic {#BatsDevlog2UpdatesToofPluginBecameMonophonic-cahkz8j0r2k0}

Toof is Bat's only Plugin. It was a polyphonic (can play multiple
notes at once) sawtooth wave synthesizer with a tweakable Moog style
low pass to give the sound some smoothness. In the latest update, Toof
was made monophonic. It can only play one note at a time therefore it
can no longer play chords. However, with the simpifications, I was
able to add a envelope to the filter.

At some point, I may re-introduce polyphony, but its not a
priority. The filter envelope can add a lot of character to bass
sounds while the next plugin will likely be a polyphonic FM
synthesizer to meet my chord needs.

<!--list-separator-->

-  Filter Envelope Modulation

    The filter envelope changes the filter frequency automatically with
    time. This is essentially the same as someone moving the filter
    frequency knob as you are playing, but automated. In the examples
    below, the "Constant Filter" synths have a similar texture
    throughout. In the "Envelope Modulated Filter", the filter
    frequency increases a bit with time, and then settles back down.

    <table>
      <tr>
        <th>Constant Filter</th>
        <th>Envelope Modulated Filter</th>
      </tr>
      <tr>
        <td>
          <audio controls src="/2024-01-14-bats-devlog-2-assets/nofilterenvelope.ogg"></audio>
        </td>
        <td>
          <audio controls src="/2024-01-14-bats-devlog-2-assets/filterenvelope.ogg"></audio>
        </td>
      </tr>
      <tr>
        <td>
          <audio controls src="/2024-01-14-bats-devlog-2-assets/nofilterenvelope2.ogg"></audio>
        </td>
        <td>
          <audio controls src="/2024-01-14-bats-devlog-2-assets/filterenvelope2.ogg"></audio>
        </td>
      </tr>
    </table>

As you can hear, in the first example the modulation starts out at a
lower frequency, builds up, and then back down. This creates a
"brassy" sound. In the second example, higher frequencies are present
at the start, and then die down, leaving just bass. This gives a
punchier sound at the start and leaves a thick low end for the
sustain.


#### Square and Triangle Waves {#BatsDevlog2UpdatesSquareandTriangleWaves-z8q2fgk0r2k0}

I added square and triangle waves were added to the core DSP libraries
waveforms, in addition to the existing Sawtooth wave. These aren't
used anywhere at the moment but can provide a different sound than
Sawtooth.


#### Playback {#BatsDevlog2UpdatesPlayback-r4z6lkk0r2k0}

Bats automatically operates on a 4 bar loop. Anything that is played
will basically be repeated every 4 bars... forever. The latest update
makes it pausible to pause the playing of the loop.


#### JSON Save Format {#BatsDevlog2UpdatesJSONSaveFormat-j8hg30m0r2k0}

JSON has replaced [Postcard](https://github.com/jamesmunns/postcard) as the save format. Postcard was initially
chosen since it's an easy to use (in Rust) binary format. Binary
formats are typically pretty fast and compact. I switched over to JSON
which is human readable. It turns out that for development, I
sometimes want to see what I saved so JSON was a good fit. I can't
remember the exact numbers, but the unit tests showed that there
actually wasn't that much of a performance hit. I imagine that this is
beacuse the decoding/encoding is relatively fast and most of the time
is spent on IO.


#### Plugin Trait Improvements {#BatsDevlog2UpdatesPluginTraitImprovements-w7w204m0r2k0}

The plugin format had some slight modifications. In hindsight, this is
an obvious abstraction to build on, but IMO its easy to get wrong and
pin yourself into a corner so I avoided it for a bit. This is
especially not critical yet as I only have 1 plugin!

The main change is that `Params` became more typed. Before, the Plugin
had to keep track if IDs manually.

```rust
/// Before
impl Plugin for MyPlugin {
    const Params: Param = &[
        Param{name: "...", id: 1, min_value: ... other_stuff }
        Param{name: "...", id: 2, min_value: ... other_stuff }
        ...
    ];

    fn set_param(id: usize, value: f32) { ... }
    fn param(id: usize) -> f32 { ... }
}
```

```rust
/// After
pub enum MyParam {
    FilterCutoff,
    OtherParam,
    ...
}

impl Param for MyParam {
    fn iter_all() -> impl Iterator<Self> { ... }
    fn name(&self) -> &'static str { ... }
    fn id(&self) -> usize { ... }
    fn min_value(&self) -> f32 { ... }
    ...
}

impl Plugin for MyPlugin {
    type Param = MyParam;

    fn set_param(p: MyParam, value: f32) {
        match p {
            MyParam::FilterCutoff => ...
            ... => ...
        }
    }

    fn param(p: MyParam) -> f32 {
        match p {
            MyParam::FilterCutoff => ...
            ... => ...
        }
    }
}
```

After the refactor, plugin's are allowed to specify a type for their
parameter. The main advantage is that the `set_param` and `param`
functions can use `match`. `match` is very useful here as the compiler
will ensure that all the cases are handled.

Although it seems like a strictly superior choice, it does add some
complexity. The code on top of the plugin can't really know about the
specifics of the plugin's `Param`. Ultimately, the wrapper code still
deals with IDs through a helper function that is automatically
implemented by the plugin.

```rust
/// Set a parameter given its id.
fn set_param_by_id(&mut self, id: u32, value: f32) -> anyhow::Result<()> {
    let param = match Self::Param::from_id(id) {
        Some(p) => p,
        None => bail!(
            "could not convert param id {id} to param for plugin {plugin_name}",
            plugin_name = Self::NAME
        ),
    };
    self.set_param(param, value);
    Ok(())
}
```


#### More Unit Tests and Cleanups {#BatsDevlog2UpdatesMoreUnitTestsandCleanups-rp4b4ym0r2k0}

Not much to say here. I especially avoided unit tests regarding the UI
that will definitely be torn down. I still actually didn't test any UI
elements, but I did move some stuff out of "UI" that is not
technically part of the UI. The biggest part that got moved out of UI
was the state management. Audio processing runs on a high priority
processing thread that should run quickly to keep up with the
load. The normal thread communicates with the processing thread
through a channel. Things like the UI, instantiating plugins, and
saving/loading happen in the normal thread. `BatsState` is a `struct`
in the normal thread that handles communicating with the audio
thread. It also attempts to build a friendly API so that the UI
doesn't have to know about the message passing under the hood.

[BatsState API](https://gitlab.com/wmedrano/bats/-/blob/cd4a7283957b4a3766e8131c21aed1099a41370f/bats-async/src/lib.rs#L116)


#### In Progress - Widgets {#BatsDevlog2UpdatesInProgressWidgets-ygthghn0r2k0}

The initial UI was a basic terminal looking UI (TUI - Terminal UI). The TUI library used was [Ratatui](https://ratatui.rs/). Ratatui is actually a pretty rich library. I took a bit more time to learn the API and built a widget for a "Track Strip".

{{< figure src="/ox-hugo/wmedrano-dev/bats-devlog2-widgets.png" >}}

At the moment, I'm unsure if I will stick with Ratatui based terminal
UI or switch to a more graphical library.


### Future {#BatsDevlog2Future-92u3j0i0r2k0}

I don't expect to do much with Bats for the rest of January. In late
December I took a detour to learn [Guile Scheme](https://www.gnu.org/software/guile/) and hooked it up to
Rust to create a text editor. For Bats, I may try to use [Steel Scheme](https://github.com/mattwparas/steel)
to perform most of the non-performance critical work like the UI.

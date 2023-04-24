+++
title = "Game of Life"
author = ["Will Medrano"]
date = 2023-04-24
lastmod = 2023-04-24T08:17:40-07:00
draft = false
+++

## Introduction {#introduction}

This is a Rust implementation of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).


### <span class="org-todo todo TODO">TODO</span> Use gif instead of static screenshot. {#use-gif-instead-of-static-screenshot-dot}

{{< figure src="/ox-hugo/screenshot.png" >}}


## Main {#main}


### Initial State {#initial-state}

```rust
struct State {
    board: Board,
    last_update: Instant,
}

impl Default for State {
    fn default() -> State {
        State {
            board: initial_board(),
            last_update: Instant::now(),
        }
    }
}
```


### Game Loop {#game-loop}

The main game loop creates a Piston window and loops through these steps:

1.  Loop through every Render event from Piston.
2.  Update the board if needed.
3.  Render the board.

<!--listend-->

```rust
fn main() {
    let mut window: PistonWindow =
        WindowSettings::new("Will's Game of Life", settings::WINDOW_SIZE)
            .exit_on_esc(true)
            .resizable(false)
            .build()
            .unwrap_or_else(|e| panic!("Failed to build window: {}", e));
    let mut state = State::default();
    while let Some(e) = window.next() {
        if let Event::Loop(Loop::Render(_)) = e {
            maybe_update_board(&mut state.board, &mut state.last_update);
            render(&mut window, &e, &state.board);
        }
    }
}
```


#### Board Update {#board-update}

The board is updated every 50 milliseconds. If less than 50 milliseconds have
passed, then nothing happens.

```rust
fn maybe_update_board(board: &mut Board, last_updated: &mut Instant) {
    let duration_per_update = Duration::from_millis(50);
    if last_updated.elapsed() <= duration_per_update {
        return;
    }
    *last_updated = Instant::now();
    *board = board.next_step();
}
```


#### Rendering {#rendering}

Piston is used for rendering. Although it is an older Rust library, it is very
easy to use. Especially for the game of Life which only requires drawing
squares. Rendering involves:

1.  Clearing the current screen.
2.  Drawing a rectangle for each cell within `board` that is alive.

<!--listend-->

```rust
fn render(window: &mut piston_window::PistonWindow, e: &piston_window::Event, board: &Board) {
    window.draw_2d(e, |c, g, _| {
        clear(Palette.background(), g);
        for (x, y) in board.iter_alive() {
            rectangle_from_to(
                Palette.foreground(),
                [x as f64, y as f64],
                [x as f64 + 1.0, y as f64 + 1.0],
                c.transform
                    .scale(settings::TILE_SIZE as f64, settings::TILE_SIZE as f64),
                g,
            );
        }
    });
}
```


## Settings {#settings}

```rust
pub const WINDOW_SIZE: (u32, u32) = (640, 480);
pub const TILE_SIZE: usize = 10;
```


## Palette {#palette}

This color palette was taken from [coolors.co](https://coolors.co/palette/ef476f-ffd166-06d6a0-118ab2-073b4c).

```rust
pub struct Palette;

impl Palette {
    pub fn background(&self) -> Color {
        // Midnight green.
        rgb_to_color([7, 59, 76])
    }

    pub fn foreground(&self) -> Color {
        // Sunglow.
        rgb_to_color([255, 209, 102])
    }
}
```


## Board {#board}

```rust
#[derive(Copy, Clone, Eq, PartialEq)]
enum Cell {
    Alive,
    NotAlive,
}

pub struct Board {
    tiles: Vec<Cell>,
    width: usize,
}

impl Board {
    pub fn new(width: usize, height: usize) -> Board {
        Board {
            tiles: vec![Cell::NotAlive; width * height],
            width,
        }
    }

    pub fn add_lives(&mut self, coords: impl Iterator<Item = (usize, usize)>) {
        for (x, y) in coords {
            self.add_life(x, y);
        }
    }

    pub fn add_life(&mut self, x: usize, y: usize) {
        let idx = self.index_for_cell(x, y);
        self.tiles[idx] = Cell::Alive;
    }

    pub fn iter_alive(&self) -> impl '_ + Iterator<Item = (usize, usize)> {
        self.tiles
            .iter()
            .enumerate()
            .filter(|(_, state)| Cell::Alive == **state)
            .map(|(idx, _)| self.cell_for_index(idx))
    }

    pub fn next_step(&mut self) -> Board {
        let mut ret = Board::new(self.width, self.height());
        let neighbors = self.count_live_neighbors();
        // Populate cells that survive to the next generation.  These are cells that are currently
        // alive and surround by 2 or 3 neighbors.
        for (x, y) in self.iter_alive() {
            let cnt = neighbors.get(&(x, y)).copied().unwrap_or_default();
            if cnt == 2 || cnt == 3 {
                ret.add_life(x, y);
            }
        }
        // Populate cells that are surrounded by exactly 3 neighbors.
        for (pos, cnt) in neighbors.iter() {
            if *cnt == 3 {
                ret.add_life(pos.0, pos.1);
            }
        }
        ret
    }
}
```

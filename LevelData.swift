let levels: [(
    [[Bool]],               // Maze logic
    (row: Int, col: Int),   // Goal Position
    (row: Int, col: Int)    // Fake Echo Position (-1, -1 if none)
)] = [
    // Level 1 (5x5) - No Fake Echo
    ([
        [true,  false,  true,    true,  true],
        [true,  true,   true,    false, true],
        [false, true,   true,    true,  false],
        [true,  false,  true,    true,  true],
        [true,  false,  true,    true,  true]//
    ], (4, 4), (-1, -1)),

    // Level 2 (5x5) - No Fake Echo
    ([
        [true,  true,  false, true,  false],
        [false, true,  true,  false, true ],
        [true,  false, true,  true,  true ],
        [true,  true,  true, false, true ],
        [false, true,  true,  true,  false]
    ], (3, 4), (-1, -1)),

    // Level 3 (5x5) - No Fake Echo (Fixed)
    ([
        [true,  false, true,  true,  true ],
        [true,  true,  true, true,  false],
        [false, true,  true,  true,  true ],
        [true,  false, false, true,  false],
        [true,  true,  true,  true,  true ]
    ], (0, 4), (-1, -1)),

    // Level 4 (6x6) - No Fake Echo
    ([
        [true,  true,  true, true,  false, false ],
        [false, true,  true,  false, true,  true ],
        [true,  true, true,  true,  true,  true],
        [true,  true,  false, false, true,  true ],
        [false, true,  true,  true,  false, true ],
        [false,  true, true,  true,  true,  true ]
    ], (1, 5), (-1, -1)),

    // Level 5 (6x6) - No Fake Echo
    ([
        [true,  false, true,  true,  false, true ],
        [true,  true,  false, true,  true,  true ],
        [false, true,  true,  true, true,  false],
        [true,  false, false, true,  true,  true ],
        [true,  true,  true,  true, true,  false],
        [true,  false, true,  true,  true,  true ]
    ], (4, 3), (-1, -1)),

    // Level 6 (6x6) - Fake Echo Introduction
    ([
        [true,  false, true,  true,  false, true ],
        [true,  true,  false, true,  true,  true ],
        [false, true,  true,  true,  false, true ],
        [true,  false, false, true,  true,  true ],
        [true,  true,  true,  false, true,  false],
        [true,  false, true,  true,  true,  true ]
    ], (5, 5), (2, 4)),

    // Level 7 (7x7) - With Fake Echo
    ([
        [true,  true,  true, false,  true, true,  true ],
        [false, true,  true,  true, false,  true, false],
        [true,  true, true,  true,  true,  true,  true ],
        [true,  true,  false, false,  true,  true, false],
        [false, true,  true,  true,  false, true,  true ],
        [true,  false, false, true,  true,  false, true ],
        [true,  true,  true,  true,  false, true,  true ]
    ], (0, 4), (3, 3)),

    // Level 8 (7x7) - With Fake Echo
    ([
        [true,  true,  false, true,  false, true,  true ],
        [false, true,  true,  false, true,  false, true ],
        [true,  false, true,  true,  true,  true,  true ],
        [true,  true,  false, true,  true,  false, false],
        [false, true,  true,  true,  true, true,  true ],
        [true,  false, false, true,  true,  false, true ],
        [true,  true,  true,  true,  false, false, true ]
    ], (0, 6), (5, 5))
]

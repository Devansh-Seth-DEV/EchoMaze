var levels: [(
    [[Bool]],               // Maze
    (row: Int, col: Int),   // Goal Position
    (row: Int, col: Int)    // Fake Echo Position (-1, -1) for none
)] {  return [
    // Level 1 (5x5) [Tutorial]
    ([
        [true,  true,  true,    true,  true],
        [true,  true,   true,    false,  true],
        [true, true,   true,    false,  true],
        [true,  false,  true,    true,  true],
        [true,  false,  true,    true,  false]
    ], (1, 4), (-1, -1)),
    
    
    // Level 2 (5x5)
    ([
        [true,  false,  true,    true,  true],
        [true,  true,   true,    false, true],
        [false, true,   true,    true,  false],
        [true,  false,  true,    true,  true],
        [true,  false,  true,    true,  true]
    ], (4, 4), (-1, -1)),
    
    
    // Level 3 (5x5)
    ([
        [true,  true,  false, true,  false],
        [false, true,  true,  false, true ],
        [true,  false, true,  true,  true ],
        [true,  true,  true, false, true ],
        [false, true,  true,  true,  false]
    ], (3, 4), (-1, -1)),
    
    
    // Level 4 (5x5)
    ([
        [true,  false, true,  true,  true ],
        [true,  true,  true, true,  false],
        [false, true,  true,  true,  true ],
        [true,  false, false, true,  false],
        [true,  true,  true,  true,  true ]
    ], (0, 4), (-1, -1)),
    
    
    // Level 5 (5x5)
    ([
        [true,  true,  true, true,  true],
        [false, false,  true,  true, false],
        [true,  true, true,  true,  true],
        [true,  true,  false, false, true],
        [false, true,  true,  true,  true],
    ], (3, 0), (-1, -1)),
    
    
    // Level 6 (5x5)
    ([
        [true,  true,  true, true,  true],
        [false, true,  true,  false, true],
        [true,  true, true,  true,  true],
        [true,  false,  false, true, false],
        [true, true,  false,  true,  true],
    ], (2, 4), (-1, -1)),
    
    
    // Level 7 (6x6) Fake Echo Point Introduced
    ([
        [true,  true,  true,  false,  true, true],
        [false, false, true,  true,   true,  false],
        [true, true,  true,  true,   false,  true],
        [true,  false, false, true,   true,  true],
        [true,  true,  true,  true,   false,  true],
        [false,  true, false,  true,   true,  true]
    ], (4, 5), (2, 4)),
    
    
    // Level 8 (6x6)
    ([
        [true,  true,  true, true,  false, false ],
        [false, true,  true,  false, true,  true ],
        [true,  true, true,  true,  true,  true],
        [true,  true,  false, false, true,  true ],
        [false, true,  true,  true,  false, true ],
        [false,  true, true,  true,  true,  true ]
    ], (1, 5), (-1, -1)),
    
    
    // Level 9 (6x6)
    ([
        [true,  false, true,  true,  false, true ],
        [true,  true,  false, true,  true,  true ],
        [false, true,  true,  true, true,  false],
        [true,  false, false, true,  true,  true ],
        [true,  true,  true,  true, true,  false],
        [true,  false, true,  true,  true,  true ]
    ], (4, 3), (-1, -1)),
   
    
    // Level 10 (6x6)
    ([
        [true,  false, true,  true,  false, true ],
        [true,  true,  false, true,  true,  true ],
        [false, true,  true,  true,  false, true ],
        [true,  false, false, true,  true,  true ],
        [true,  true,  true,  false, true,  false],
        [true,  false, true,  true,  true,  true ]
    ], (5, 5), (2, 4)),
    
    
    // Level 11 (6x6)
    ([
        [true,  true, true,  false,  true, true],
        [true,  false,  true, true,  true,  true],
        [true, true,  true,  true,  false, false],
        [false,  true, true, true,  true,  true],
        [false,  false,  true,  true, false,  true],
        [true,  true, true,  true,  false,  true]
    ], (0, 2), (4, 0)),
    
    
    // Level 12 (6x6)
    ([
        [true,  true,   true,   false,  true,    true],
        [true,  false,   true,   true,  true,    false],
        [true,  false,   false,   true,  true,    true],
        [true,  true,   true,   true,  false,    true],
        [false,  true,   false,   true,  true,    true],
        [true,  true,   true,   true,  false,    true]
    ], (5, 3), (-1, -1)),
    
    
    // Level 13 (6x6)
    ([
        [true,  true,   true,   true,  false,   false],
        [true,  false,   true,   true,  true,    true],
        [true,  true,   true,   false,  false,    true],
        [false,  true,   true,   true,  true,    true],
        [true,  true,   false,   true,  true,    false],
        [true,  false,   false,   true,  true,    true]
    ], (1, 2), (5, 1)),
    
    
    // Level 14 (6x6)
    ([
        [true,  true,   true,   false,  true,    true],
        [true,  false,   false,   true,  true,    true],
        [true,  true,   true,   true,  false,    false],
        [false,  false,   true,   false,  true,    true],
        [false,  true,   true,   true,  true,    true],
        [true,  true,   false,   false,  true,    true]
    ], (1, 5), (4, 0)),
    
    
    // Level 15 (7x7)
    ([
        [true,  true,  true, false,  false, true,  true ],
        [false, true,  true,  true, true,  true, false],
        [true,  true, true,  true,  true,  true,  true ],
        [true,  true,  false, false,  true,  true, false],
        [false, true,  true,  true,  false, true,  true ],
        [true,  false, false, true,  true,  false, true ],
        [true,  true,  true,  true,  false, true,  true ]
    ], (1, 4), (3, 3)),
    
    
    // Level 16 (7x7)
    ([
        [true,  true,  false, true,  false, true,  false ],
        [false, true,  true,  false, true,  false, true ],
        [true,  false, true,  true,  true,  true,  true ],
        [true,  true,  false, true,  true,  false, true],
        [false, true,  true,  true,  true, true,  true ],
        [true,  false, false, true,  true,  false, true ],
        [true,  true,  true,  true,  false, false, true ]
    ], (3, 6), (5, 5)),
    
    
    // Level 17 (7x7)
    ([
        [true,  true,   true,   false,  true,    true,   false],
        [true,  false,   true,   false,  true,    false,   true],
        [true,  true,   true,   true,  true,    true,   true],
        [false,  true,   false,   false,  true,    false,   true],
        [true,  true,   true,   false,  false,    true,   true],
        [false,  false,   true,   true,  true,    true,   false],
        [true,  true,   true,   false,  false,    true,   true]
    ], (6, 6), (4, 3)),
    
    
    // Level 18 (7x7)
    ([
        [true,   true,   true,   true,   true,   false,   true],
        [true,   false,   false,   false,   true,   false,   true],
        [true,   true,   true,   true,   true,   false,   true],
        [true,   false,   false,   true,   false,   true,   true],
        [true,   true,   false,   true,   true,   true,   false],
        [true,   false,   false,   false,   true,   true,   false],
        [true,   true,   true,   true,   true,   true,   false]
    ], (5, 4), (4, 2)),
    
    
    // Level 19 (7x7)
    ([
        [true,   true,   true,   false,   true,   true,   true],
        [true,   false,   false,   true,   false,   false,   true],
        [true,   true,   true,   true,   true,   false,   true],
        [true,   false,   true,   true,   true,   false,   true],
        [true,   true,   false,   true,   true,   true,   true],
        [false,   true,   false,   false,   true,   false,   true],
        [true,   true,   true,   true,   true,   true,   false]
    ], (3, 3), (5, 2)),
    
    
    // Level 20 (7x7)
    ([
        [true,   true,   true,   false,   true,   true,   true],
        [true,   true,   true,   true,   true,   false,   true],
        [false,   true,   false,   true,   false,   true,   true],
        [true,   true,   true,   true,   true,   false,   true],
        [true,   false,   false,   true,   true,   true,   true],
        [true,   true,   true,   true,   false,   true,   true],
        [true,   false,   true,   true,   true,   true,   true]
    ], (6, 2), (-1, -1)),
    
    
    // Level 21 (7x7)
    ([
        [true,   true,   true,   true,   true,   true,   true],
        [true,   false,   true,   false,   false,   false,   true],
        [true,   false,   true,   true,   true,   true,   true],
        [false,   true,   true,   false,   true,   true,   true],
        [true,   false,   false,   true,   true,   true,   true],
        [true,   true,   true,   true,   false,   true,   false],
        [true,   false,   true,   true,   true,   true,   true]
    ], (5, 5), (5, 6)),
    
    
    // Level 22 (7x7)
    ([
        [true,   true,   true,   true,   false,   false,   true],
        [false,   true,   false,   true,   true,   true,   true],
        [true,   true,   true,   false,   true,   false,   true],
        [true,   false,   true,   true,   false,   true,   true],
        [true,   true,   true,   false,   true,   true,   false],
        [true,   false,   false,   true,   true,   true,   true],
        [false,   true,   true,   true,   true,   false,   true]
    ], (4, 2), (-1, -1)),
    
    
    // Level 23 (7x7)
    ([
        [true,   true,   true,   false,   true,   true,   true],
        [true,   false,   true,   true,   false,   true,   false],
        [true,   true,   true,   false,   true,   true,   true],
        [true,   true,   true,   true,   true,   false,   true],
        [false,   true,   false,   false,   true,   true,   true],
        [true,   true,   true,   true,   false,   false,   true],
        [true,   false,   true,   true,   false,   true,   true]
    ], (6, 3), (5, 4)),
    
    
    // Level 24 (7x7)
    ([
        [true,   true,   true,   true,   true,   false,   true],
        [true,   false,   false,   false,   true,   true,   true],
        [true,   true,   true,   false,   true,   false,   true],
        [true,   false,   true,   false,   true,   true,   false],
        [true,   true,   true,   true,   true,   true,   false],
        [true,   false,   false,   false,   false,   true,   true],
        [false,   true,   true,   true,   true,   true,   true]
    ], (4, 2), (6, 0)),
    
    
    // Level 25 (7x7)
    ([
        [true,   true,   true,   false,   true,   true,   true],
        [true,   false,   true,   true,   true,   false,   true],
        [false,   true,   true,   true,   true,   true,   true],
        [true,   true,   true,   false,   true,   false,   true],
        [true,   false,   false,   true,   true,   true,   true],
        [true,   true,   true,   true,   false,   true,   true],
        [true,   false,   true,   true,   true,   true,   true]
    ], (2, 4), (-1, -1)),
    
    
    // Level 26 (7x7)
    ([
        [true,   true,   true,   true,   false,   false,   true],
        [false,   true,   false,   true,   true,   true,   true],
        [true,   true,   true,   false,   true,   false,   true],
        [true,   false,   true,   true,   false,   true,   true],
        [true,   true,   true,   false,   true,   true,   false],
        [true,   false,   false,   true,   true,   true,   true],
        [false,   true,   true,   true,   true,   false,   true]
    ], (2, 4), (-1, -1)),
    
    
    // Level 27 (8x8)
    ([
        [true,   true,   true,   true,   false,   true,   true,   true],
        [true,   false,   false,   true,   true,   true,   true,   true],
        [true,   true,   true,   true,   false,   false,   true,   true],
        [true,   false,   true,   false,   true,   true,   true,   false],
        [false,   true,   true,   true,   false,   true,   true,   true],
        [true,   false,   true,   false,   true,   true,   true,   true],
        [true,   true,   true,   true,   true,   false,   true,   true],
        [true,   true,   false,   true,   true,   true,   false,   true]
    ], (7, 5), (-1, -1)),
    
    
    // Level 28 (8x8)
    ([
        [true,   true,   true,   true,   true,   true,   false,   true],
        [true,   false,   true,   false,   true,   true,   true,   true],
        [true,   true,   true,   true,   true,   false,   false,   true],
        [true,   false,   true,   true,   false,   true,   true,   true],
        [true,   true,   true,   true,   true,   true,   false,   true],
        [true,   false,   false,   true,   true,   true,   true,   true],
        [false,   true,   true,   true,   false,   false,   true,   true],
        [true,   true,   true,   true,   true,   true,   true,   true]
    ], (7, 7), (6, 0)),
    
    
    // Level 29 (8x8)
    ([
        [true,   true,   true,   true,   true,   true,   false,   true],
        [true,   false,   true,   false,   true,   true,   true,   true],
        [true,   true,   true,   false,   true,   false,   false,   true],
        [true,   false,   true,   true,   false,   true,   true,   true],
        [true,   true,   true,   false,   true,   true,   false,   true],
        [true,   false,   false,   true,   true,   true,   true,   true],
        [true,   true,   true,   true,   true,   false,   true,   true],
        [true,   true,   true,   true,   true,   true,   true,   true]
    ], (6, 0), (2, 3)),
    
    
    // Level 30 (8x8)
    ([
        [true,   true,   true,   false,   true,   true,   true,   true],
        [false,   true,   true,   true,   true,   false,   true,   true],
        [true,   true,   false,   true,   true,   true,   true,   true],
        [true,   false,   true,   false,   true,   true,   false,   true],
        [true,   true,   true,   true,   false,   true,   true,   true],
        [false,   true,   false,   true,   true,   true,   true,   true],
        [true,   true,   true,   true,   true,   false,   true,   false],
        [true,   true,   true,   true,   true,   true,   true,   false]
    ], (6, 3), (7, 7)),
    
    
    // Level 31 (8x8)
    ([
        [true,   true,   true,   false,   true,   true,   true,   true],
        [false,   false,   true,   false,   true,   false,   false,   true],
        [true,   true,   true,   true,   false,   true,   true,   true],
        [true,   false,   false,   true,   false,   false,   true,   false],
        [true,   true,   false,   true,   true,   true,   true,   true],
        [false,   true,   true,   true,   true,   false,   false,   true],
        [true,   true,   true,   false,   true,   true,   true,   true],
        [true,   false,   false,   true,   true,   false,   false,   false]
    ], (5, 4), (3, 5)),
    
    
    // Level 32 (8x8)
    ([
        [true,   true,   true,   false,   true,   true,   true,   true],
        [false,   false,   true,   true,   true,   false,   true,   true],
        [true,   true,   true,   false,   false,   true,   true,   false],
        [true,   true,   true,   true,   false,   true,   false,   true],
        [true,   true,   false,   true,   false,   true,   true,   false],
        [false,   false,   false,   true,   true,   true,   true,   true],
        [false,   true,   true,   true,   true,   true,   true,   false],
        [true,   false,   false,   true,   false,   true,   false,   false]
    ], (1, 7), (3, 4)),
    
    
    // Level 33 (8x8)
    ([
        [true, true, false, true, true, true, true, true],
        [false, true, true, true, false, false, true, true],
        [true, true, true, true, true, false, false, true],
        [true, false, false, true, false, true, true, true],
        [true, true, true, true, true, true, true, true],
        [false, false, false, true, false, true, true, false],
        [true, true, true, true, false, true, true, false],
        [true, false, false, true, false, false, false, false]
    ], (1, 7), (6, 4)),
  
    
    // Level 34 (8x8)
    ([
        [true, true, false, true, true, true, true, true],
        [true, false, true, true, false, false, true, true],
        [true, true, true, true, true, false, false, true],
        [true, false, false, true, false, true, true, true],
        [true, true, true, true, true, true, false, true],
        [true, false, false, true, false, true, true, false],
        [false, true, true, true, true, true, true, false],
        [false, false, false, true, false, false, false, false]
    ], (6, 5), (6, 0)),
    
    
    // Level 35 (8x8)
    ([
        [true, true, false, true, true, true, true, true],
        [true, false, true, true, false, true, true, false],
        [true, true, true, false, true, true, true, true],
        [true, true, true, true, true, false, true, false],
        [false, false, true, true, true, true, true, true],
        [true, true, true, true, false, true, true, false],
        [false, false, true, true, true, false, true, true],
        [false, false, false, true, false, false, false, true]
    ], (4, 7), (6, 5)),
    
    
    // Level 36 (8x8)
    ([
        [true, true, false, true, true, true, true, true],
        [false, true, true, true, false, false, true, false],
        [true, true, true, true, true, false, false, true],
        [true, false, true, true, false, true, true, true],
        [true, true, true, true, true, true, true, true],
        [false, false, false, true, false, true, true, false],
        [true, true, true, true, false, true, true, false],
        [true, false, false, true, false, false, false, false]
    ], (3, 2), (3, 1)),
    
    
    // Level 37 (9x9)
    ([
        [true, true, true, false, true, true, true, true, true],
        [false, false, true, true, true, false, true, false, true],
        [true, true, true, false, true, false, true, true, true],
        [true, false, true, true, false, true, true, true, true],
        [true, true, false, true, true, true, true, false, false],
        [true, false, true, true, true, false, true, true, true],
        [true, true, true, false, true, true, true, false, true],
        [false, true, true, true, true, true, false, true, true],
        [false, false, true, false, true, true, true, false, false]
    ], (7, 2), (7, 6)),
    
    
    // Level 38 (9x9)
    ([
        [true, true, true, true, true, true, true, true, true],
        [true, true, true, false, false, true, true, false, true],
        [true, false, true, true, true, true, false, true, true],
        [false, true, false, true, true, false, true, true, true],
        [true, true, true, true, true, true, true, true, false],
        [true, false, false, true, true, true, true, false, true],
        [true, true, true, true, true, true, true, true, false],
        [true, true, false, true, true, true, false, true, false],
        [false, false, false, false, true, false, false, false, false]
    ], (2, 8), (8, 0)),
    
    
    // Level 39 (9x9)
    ([
        [true, true, false, true, true, true, true, false, true],
        [true, false, true, false, true, true, true, false, true],
        [true, true, true, true, false, true, true, true, true],
        [false, true, false, false, true, true, true, true, false],
        [true, true, true, true, true, false, true, true, true],
        [false, false, true, true, true, true, true, false, false],
        [true, true, true, false, true, true, true, true, false],
        [false, true, false, true, true, true, false, false, false],
        [true, true, true, false, false, true, true, true, true]
    ], (3, 6), (-1, -1)),
    
    // Level 40 (9x9)
    ([
        [true, true, false, true, true, false, true, true, true],
        [false, true, false, true, false, true, false, true, false],
        [true, true, true, true, true, true, true, true, true],
        [true, false, true, true, false, false, false, true, false],
        [true, true, true, true, true, true, true, true, false],
        [false, false, true, false, true, true, true, true, true],
        [true, true, true, false, true, true, true, false, true],
        [false, true, false, true, false, false, true, true, false],
        [true, true, true, true, true, false, false, false, false]
    ], (6, 8), (0, 5)),
]}

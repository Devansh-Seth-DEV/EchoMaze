//
//  LevelData.swift
//  EchoMaze
//
//  Created by Batch - 2 on 20/02/25.
//

let levels: [([[Bool]], (row: Int, col: Int))] = [
    ([
        [true,  true,  false, true,  true ],
        [false, true,  false, true,  false],
        [true,  true,  true,  true,  true ],
        [true, true,  false, true,  true],
        [true,  false, true,  true,  false ]
    ], (3, 4)),  // Level 1 (5x5 grid, goal at bottom-right)
    
    ([
        [true,  false, true,  true,  true ],
        [true,  true,  false, false, true ],
        [false, true,  true,  true,  true ],
        [true,  false, false, true,  false],
        [true,  true,  true,  true,  true ]
    ], (0, 4)),  // Level 2
    // Add more levels here
]

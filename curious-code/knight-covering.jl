begin
    fileset = 'a':'h'
    rankset = '1':'8'

    # A vector containing every position on the board.
    board = (f*r for f in fileset for r in rankset) |> collect

    # Linearly sequence the lower-left 
    # quadrant 'a':'d' × '1':'4', mapping
    # 1 ↦ "a1"
    # 2 ↦ "b1"
    # 3 ↦ "c1"
    # 4 ↦ "d1"
    # 5 ↦ "a2"
    # ⋮
    # 16 ↦ "d4".
    function picksquare(n::Int)
        u = (n - 1) % 4 + 1
        v = (n - 1) ÷ 4 + 1
        fileset[u] * rankset[v]
    end

    # Given a position, return the corresponding position
    # after a 90° counterclockwise rotation of the board.
    function rotate(pos)
        # findfirst doesn't work on a UnitRange, but does
        # work on a String
        u = findfirst(pos[1], *(fileset...))
        v = findfirst(pos[2], *(rankset...))
        fileset[9 - v] * rankset[u]
    end

    function fullrotate(knightset)
		# Duplicates a set of positions by rotating 90°, 180°, 270°.
        union(
            knightset,
            rotate.(knightset),
            (rotate ∘ rotate).(knightset),
            (rotate ∘ rotate ∘ rotate).(knightset)
        )
    end

    function attacked_by(pos::String)
        pos = lowercasefirst(pos)
        
        valid(square) = square[1] ∈ fileset && square[2] ∈ rankset
        !valid(pos) && return("Invalid position.")
    
        signs = (-1,1)
        stepsizes = (1,2)
        
        moves = ((colsign*colstep, rowsign*(3 - colstep)) 
                for colsign in signs, rowsign in signs 
                for colstep in stepsizes)

        targets = (Tuple(pos) .+ m for m in moves) |> collect
        validtargets = filter(valid, targets)
        validtargets .|> prod |> Set
    end

    function covered_by(pos::String)
        push!(attacked_by(pos), pos)
    end

    # Search space: Symmetric (C₄ symmetry) placements of 12
    # knights. Size of search space is 
    #  binomial(16,3)
    # which is 560.
    counter = 0
    for i = 1:16, j = i+1:16, k = j+1:16
        # ↑ Choose 3 distinct integers in range 1:16
        counter += 1
        # Now convert [i,j,k] to a trio of positions in
        # the lower-left quadrant:
        knightset = picksquare.([i, j, k])
        # Copy to other 3 quadrants by rotation.
        fullset = fullrotate(knightset)
        # Take the union of all squares attacked_by these
        # 12 knights, along with the 12 occupied squares.
        coveredset = union(covered_by.(fullset)...)
        if board ⊆ coveredset
            println(counter, " ", fullset)
        end
		# Output:
		# 462 ["c2", "c3", "d3", "g3", "f3", "f4", "f7", "f6", "e6", "b6", "c6", "c5"]
		# 529 ["b3", "c3", "c4", "f2", "f3", "e3", "g6", "f6", "f5", "c7", "c6", "d6"]

    end

	# Three separate knights are needed to cover these three corner positions:
	∩(attacked_by.(["a1", "a2", "b2"])...) |> isempty
	# true

	# The set of positions that can attack the lower left 2 × 2 corner and
	# the set that can attack the upper left corner are disjoint.
	lower_left_corner = union(covered_by.(["a1", "a2", "b1", "b2"])...)
	upper_left_corner = union(covered_by.(["a8", "a7", "b8", "b7"])...)
	lower_left_corner ∩ upper_left_corner |> isempty
	# true
		
	# Then, by symmetry, at least 4*3 = 12 knights -- three for each of the four
	# corners -- are needed.
	
end

ROW_NUMBER(), RANK(), DENSE_RANK() — Quick Notes

Sample Data
-----------
Amount
100
100
90
80


1. ROW_NUMBER()
----------------
Syntax:
ROW_NUMBER() OVER(ORDER BY Amount DESC)

Result:
100 -> 1
100 -> 2
90  -> 3
80  -> 4

Behavior:
- Always unique
- No ties
- Sequential numbering

Use Cases:
- Latest order
- First transaction
- Removing duplicates
- Exact row sequencing

Memory Trick:
"Every row gets a unique number"


2. RANK()
----------
Syntax:
RANK() OVER(ORDER BY Amount DESC)

Result:
100 -> 1
100 -> 1
90  -> 3
80  -> 4

Behavior:
- Same values share same rank
- Skips numbers after ties

Sequence:
1,1,3,4

Use Cases:
- Competition ranking
- Leaderboards
- Olympic-style ranking

Memory Trick:
"Ties create gaps"


3. DENSE_RANK()
----------------
Syntax:
DENSE_RANK() OVER(ORDER BY Amount DESC)

Result:
100 -> 1
100 -> 1
90  -> 2
80  -> 3

Behavior:
- Same values share same rank
- No skipped numbers

Sequence:
1,1,2,3

Use Cases:
- Second highest salary
- Top N unique values
- Distinct ranking levels

Memory Trick:
"No gaps in ranking"


Important Interview Trap
-------------------------
Question:
"Find second highest salary"

Using RANK():
100
100
90

Ranks:
1
1
3

No rank 2 exists ❌

Correct approach:
Use DENSE_RANK() = 2 ✅


Quick Comparison
-----------------
ROW_NUMBER()
- Unique numbering
- No ties

RANK()
- Ties allowed
- Gaps appear

DENSE_RANK()
- Ties allowed
- No gaps
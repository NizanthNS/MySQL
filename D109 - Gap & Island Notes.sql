# SQL Gap & Island Notes (Streak Problems)

## Step 1: Understand the Streak Types

### 1. Current Streak

**Definition:**
The streak that contains the user's most recent activity date.

Example:

Activity Dates:

2025-01-01
2025-01-02
2025-01-03

2025-01-10
2025-01-11

2025-01-20
2025-01-21
2025-01-22

Streaks:

* 2025-01-01 → 2025-01-03 (3 days)
* 2025-01-10 → 2025-01-11 (2 days)
* 2025-01-20 → 2025-01-22 (3 days)

Most recent activity date:

2025-01-22

Result:

* Current_Streak = 3
* Start_Date = 2025-01-20
* End_Date = 2025-01-22

How to identify:

Order streaks by End_Date DESC and pick the first one.

---

### 2. Longest Streak

**Definition:**
The streak with the maximum length.

Example:

* 2025-01-01 → 2025-01-03 (3 days)
* 2025-01-10 → 2025-01-11 (2 days)
* 2025-01-20 → 2025-01-22 (3 days)

Longest streak length:

3 days

If multiple streaks have the same length:

Choose the most recent streak if specified.

Typical ordering:

ORDER BY Streak DESC, End_Date DESC

---

### 3. Total Streaks

**Definition:**
The number of separate streak groups.

Example:

* 2025-01-01 → 2025-01-03
* 2025-01-10 → 2025-01-11
* 2025-01-20 → 2025-01-22

Result:

Total_Streaks = 3

---

### 4. All Streaks

**Definition:**
Return every streak.

Example Output:

## User_ID | Start_Date | End_Date | Streak_Length

101     | 2025-01-01 | 2025-01-03 | 3
101     | 2025-01-10 | 2025-01-11 | 2
101     | 2025-01-20 | 2025-01-22 | 3

No ranking required.

---

### 5. Longest Streak Length Only

**Definition:**
Return only the maximum streak length.

Example:

## User_ID | Longest_Streak

101     | 3

Typically:

MAX(Streak)

---

### 6. Users With At Least N-Day Streak

Example:

Find users whose longest streak is at least 4 days.

Logic:

MAX(Streak) >= 4

Typical filter:

HAVING MAX(Streak) >= 4

---

# Standard Gap & Island Pattern

### Step 1: Remove Duplicate Dates

Use when multiple activities can occur on the same date.

SELECT DISTINCT User_ID, Activity_Date

---

### Step 2: Create Row Number

Assign sequence numbers within each user.

ROW_NUMBER() OVER (
PARTITION BY User_ID
ORDER BY Activity_Date
)

---

### Step 3: Create Group Key

Generate a common key for consecutive dates.

DATE_SUB(Activity_Date, INTERVAL RN DAY)

All consecutive dates produce the same Group_Key.

---

### Step 4: Build Streaks

GROUP BY User_ID, Group_Key

Calculate:

* COUNT(*) AS Streak
* MIN(Activity_Date) AS Start_Date
* MAX(Activity_Date) AS End_Date

Now you have:

User_ID
Streak
Start_Date
End_Date

---

# Quick Decision Table

| Question Type         | Solution                |
| --------------------- | ----------------------- |
| Current Streak        | Latest End_Date         |
| Longest Streak        | Largest Streak          |
| Total Streaks         | Count streak groups     |
| All Streaks           | Return all groups       |
| Longest Streak Length | MAX(Streak)             |
| At Least N Days       | HAVING MAX(Streak) >= N |

---

# Mental Shortcut

After creating:

User_ID
Streak
Start_Date
End_Date

Everything becomes easy:

* Current Streak → Latest End_Date
* Longest Streak → Largest Streak
* Total Streaks → Count Groups
* All Streaks → Return All Rows
* At Least N Days → Filter on MAX(Streak)

Master this pattern and almost every SQL streak question becomes a small variation of the same solution.

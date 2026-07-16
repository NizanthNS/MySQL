# Filtering = Refers to the process of selecting elements
#             From an array that match a given condition

import numpy as np

ages = np.array([[21, 17, 19, 20, 16, 30, 18, 65],
                 [39, 22, 15, 99, 18, 19, 20, 21]])

# teen = ages[ages < 18]
# adults = ages[(ages >= 18) & (ages < 65)]
# seniors = ages[ages >= 65]
# evens = ages[ages % 2 == 0]
# odds = ages[ages % 2 != 0]

# print(teen)
# print(adults)
# print(seniors)
# print(evens)
# print(odds)

adults = np.where(ages >= 18, ages, 0)

print(adults)

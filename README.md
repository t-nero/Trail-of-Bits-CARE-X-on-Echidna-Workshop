# Trail-of-Bits-CARE-X-on-Echidna-Workshop
Author: [t-nero](https://twitter.com/NonFungibleNero) (Discord: Kenshin#1165)

## Overview
From the given time, I managed to write 28 invariants in total which consist of following:
* `add()`: 7 invariants
* `sub()`: 6 invariants
* `avg()`: 4 invariants
* `gavg()`: 5 invariants
* `pow()`: 6 invariants

## Invariants Details
To give an overview of invariants, the following is the list of all invariants that I have written. More descriptive about each invariant can be found in the `EchidnaTest.sol`

### Addition (Total: 7)
* Assertion 1: x+y == y+x
* Assertion 2: x+z == z+x
* Assertion 3: y+z == z+y
* Assertion 4: (x+y)+z == x+(y+z) == (x+z)+y
* Assertion 5: x+0 == x
* Assertion 6: x+1 > x
* Assertion 7: x+(-x) == 0

### Subtraction (Total: 6)
* Assertion 1: x-y > x when y is negative and x-y < x when y is positive
* Assertion 2: x-y == -(y-x)
* Assertion 3: x-1 < x
* Assertion 4: x-0 == x
* Assertion 5: 0-x == -x when x is positive, and 0-x = x when x is negative
* Assertion 6: x-x == 0

### Average (Total: 9)
#### Arithmetic Average (Subtotal: 4)
* Assertion 1: avg(x,0) == x/2
* Assertion 2: avg(x,x) == x
* Assertion 3: x <= avg(x,y) <= y || x >= avg(x,y) >= y
* Assertion 4: avg(x,y) == avg(y,x)

#### Geometric Average (Subtotal: 5)
* Assertion 5: gavg(x,0) == 0
* Assertion 6: gavg(x,1) == sqrt(x)
* Assertion 7: gavg(x,x) == x
* Assertion 8: gavg(x,y) == gavg(y,x)
* Assertion 9: x <= gavg(x,y) <= y || x >= gavg(x,y) >= y

### Power (Total: 6)
* Assertion 1: x^0 == 1
* Assertion 2: x^1 == x
* Assertion 3: x^(y+1) == x^(1+y) == x^y * x
* Assertion 4: x^(y+z) == x^(z+y) ==  x^y * x^z
* Assertion 5: x^(y-z) == x^y / x^z
* Assertion 6: (x^y)^z == (x^z)^y == x^(y*z) == x^(z*y)

## How to run
I already prepared 2 config files which act as its name
* `exclude.yaml`: use this config to exclude all the wrapper functions from being tested.
* `whitelist.yaml`: you can add `#` at the start of any line to comment that function from being tested, use this config to filter only function is the list to be tested.

### Test all exclude the wrapper functions
```bash
./echidna-test EchidnaTest.sol --contract Test --test-mode assertion --corpus-dir corpus --test-limit <total_test_limit> --config exclude.yaml
```

### Test only specific invariants
```bash
./echidna-test EchidnaTest.sol --contract Test --test-mode assertion --corpus-dir corpus --test-limit <total_test_limit> --config whitelist.yaml
```
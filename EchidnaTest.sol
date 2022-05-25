// SPDX-License-Identifier: BSD-4-Clause
pragma solidity ^0.8.1;

import "ABDKMath64x64.sol";

contract Test {
    int128 internal zero = ABDKMath64x64.fromInt(0);
    int128 internal one = ABDKMath64x64.fromInt(1);

    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;
    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    event Value(string, int64);

    function debug(string calldata x, int128 y) public {
        emit Value(x, ABDKMath64x64.toInt(y));
    }

    function add(int128 x, int128 y) public returns (int128) {
        return ABDKMath64x64.add(x, y);
    }

    function sub(int128 x, int128 y) public returns (int128) {
        return ABDKMath64x64.sub(x, y);
    }

    function mul(int128 x, int128 y) public returns (int128) {
        return ABDKMath64x64.mul(x, y);
    }

    function div(int128 x, int128 y) public returns (int128) {
        return ABDKMath64x64.div(x, y);
    }

    function fromInt(int256 x) public returns (int128) {
        return ABDKMath64x64.fromInt(x);
    }

    function pow(int128 x, uint256 y) public returns (int128) {
        return ABDKMath64x64.pow(x, y);
    }

    function neg(int128 x) public returns (int128) {
        return ABDKMath64x64.neg(x);
    }

    function inv(int128 x) public returns (int128) {
        return ABDKMath64x64.inv(x);
    }

    function sqrt(int128 x) public returns (int128) {
        return ABDKMath64x64.sqrt(x);
    }

    function avg(int128 x, int128 y) public returns (int128) {
        return ABDKMath64x64.avg(x, y);
    }

    function gavg(int128 x, int128 y) public returns (int128) {
        return ABDKMath64x64.gavg(x,y);
    }

    /*
    ==============================
    |          Addition          |
    ==============================
    Total assertions: 7

    Assertion 1: x+y == y+x
        Testing the commutative property of addition and ensuring that x+y is in the range of 64.64.
    
    Assertion 2: x+z == z+x
        This assertion will only be executed if the previous assertion passes. Testing the commutative
        property of addition and ensuring that x+z falls inside the range of 64.64.

    Assertion 3: y+z == z+y
        This assertion will only be executed if both assertions 1 and 2 pass. Testing the commutative
        property of addition and ensuring that y+z is inside the range of 64.64.
    
    Assertion 4: (x+y)+z == x+(y+z) == (x+z)+y
        This assertion will only be executed if the previous three assertions pass. Evaluation of the
        associative property of addition. 
    */
    function testAdd(int128 x, int128 y, int128 z) public {
        // Assertion 1: x+y == y+x
        try this.add(x, y) returns (int128 xy) {
            try this.add(y, x) returns (int128 yx) {
                assert(xy == yx);

                // Assertion 2: x+z == z+x
                try this.add(x, z) returns (int128 xz) {
                    try this.add(z, x) returns (int128 zx) {
                        assert(xz == zx);

                        // Assertion 3: y+z == z+y
                        try this.add(y, z) returns (int128 yz) {
                            try this.add(z, y) returns (int128 zy) {
                                assert(yz == zy);

                                // Assertion 4: (x+y)+z == x+(y+z) == (x+z)+y
                                try this.add(xy, z) returns (int128 xy_z) {
                                    try this.add(x, yz) returns (int128 x_yz) {
                                        assert(xy_z == x_yz);

                                        try this.add(xz, y) returns (int128 xz_y) {
                                            // Assuming the above assertion is true we can conclude that
                                            // xy_z == xz_y.
                                            assert(x_yz == xz_y);
                                        } catch {
                                            // Assuming both (x+y)+z and x+(y+z) are true (x+z)+y should
                                            // also be true.
                                            assert(false);
                                        }
                                    } catch {} // Intentionally left blank, it can be reverted on overflow.
                                } catch {} // Intentionally left blank, it can be reverted on overflow.
                            } catch {
                                // If add(y, z) succeeded, add(z, y) should not be reverted.
                                assert(false);
                            }
                        } catch {} // Intentionally left blank, it can be reverted on overflow.
                    } catch {
                        // If add(x, z) succeeded, add (z, x) should not be reverted.
                        assert(false);
                    }
                } catch {} // Intentionally left blank, it can be reverted on overflow.
            } catch {
                // If add(x, y) succeeded, add(y, x) should not be reverted.
                assert(false);
            }
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 5: x+0 == x
        Testing the identity element property, adding zero to any number should still result the same.
    */
    function testAddZero(int128 x) public {
        // Assertion 5: x+0 == x
        try this.add(x, zero) returns (int128 x0) {
            assert(x == x0);
        } catch {
            if (x >= MIN_64x64 && x <= MAX_64x64) {
                // If x is in the range, it should not be reverted.
                assert(false);
            }
        }
    }

    /*
    Assertion 6: x+1 > x
        Testion the successor property, for any integer x, the integer x+1 should be greater than x.
    */
    function testAddOne(int128 x) public {
        // Assertion 6: x+1 > x
        try this.add(x, one) returns (int128 x1) {
            assert(x1 > x);
        }
        catch {
            // x + 1 should not be reverted if it was not overflow.
            if (x < this.sub(MAX_64x64, one)) {
                assert(false);
            }
        }
    }

    /*
    Assrtion 7: x+(-x) == 0
        Testing the additive inversion. This also tests whether the 'neg()' function generates the
        correct inverse integer.
    */
    function testInverseAdd(int128 x) public {
        // Assrtion 7: x+(-x) == 0
        try this.add(x, this.neg(x)) returns (int128 _x) {
            assert(_x == 0);
        }
        catch {
            if (x != MIN_64x64 && x <= MAX_64x64) {
                // If x is in the range, it should not be reverted.
                assert(false);
            }
        }
    }

    /*
    =================================
    |          Subtraction          |
    =================================
    Total assertion: 6

    Assertion 1: x-y > x when y is negative and x-y < x when y is positive
        Testing that if y is negative then the operation should be invert to additive as the real
        number unary operation fact x - (-y) = x+y
    
    Assertion 2: x-y == -(y-x)
        Testing the anti-commutative property of subtraction.
    */
    function testSubComm(int128 x, int128 y) public {
        require(x != 0 && y != 0, "Assumed that x&y must not be zero");
        bool isNegativeY = y < 0;

        try this.sub(x, y) returns (int128 xy) {
            // Assertion 1: x-y > x when y is negative and x-y < x when y is positive
            if (isNegativeY) {
                assert(xy > x && x != 0);
            }
            else {
                assert(xy < x && x != 0);
            }
            
            // Assertion 2: x-y == -(y-x)
            try this.sub(y, x) returns (int128 yx) {
                yx = this.neg(yx);
                assert(xy == yx);
            } catch {} // Intentionally left blank, it can be reverted on overflow.
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 3: x-1 < x
        Testing the predecessor property of subtraction, for any integer x, the integer x-1 must
        be less than x, given that x != MIN.
    */
    function testSubOne(int128 x) public {
        // Assertion 3: x-1 < x
        bool isPositiveX = x > zero;
        try this.sub(x, one) returns (int128 x1) {
            assert(x1 < x);
        }
        catch {
            if (x > this.add(MIN_64x64, one)) {
                // It should not be reverted if x-1 is not underflow.
                assert(false);
            }
        }
    }

    /*
    Assertion 4: x-0 == x
        Testing that the result should remain the same if the subtrahend is 0.

    Assertion 5: 0-x == -x when x is positive, and 0-x = x when x is negative
        Testing that the result of 0 as minuend be subtracted with any integer x will result in
        negative or positive x.
    */
    function testSubZero(int128 x) public {
        // Assertion 4: x-0 == x
        try this.sub(x, zero) returns (int128 x0) {
            assert(x == x0);
        }
        catch {
            if (x >= MIN_64x64 && x <= MAX_64x64) {
                // If x is in the range, it should not be reverted.
                assert(false);
            }
        }

        // Assertion 5: 0-x == -x when x is positive, and 0-x = x when x is negative
        try this.sub(zero, x) returns (int128 _x) {
            assert(_x == this.neg(x));
            assert(_x == this.neg(x));
        }
        catch {
            if (x >= MIN_64x64 && x <= MAX_64x64) {
                // If x is in the range, it should not be reverted.
                assert(false);
            }
        }
    }

    /*
    Assertion 6: x-x == 0
        Testing that for any integer x be subtracted by itself should result in 0 regardless that x
        is negative or positive. This also testing the `neg()` function that will it generate the
        right inverse integer.
    */
    function testInverseSub(int128 x) public {
        // Assertion 6: x-x == 0
        try this.sub(x, x) returns (int128 _x) {
            assert(_x == zero);
        }
        catch {
            if (x >= MIN_64x64 && x <= MAX_64x64) {
                // If x is in the range, it should not be reverted.
                assert(false);
            }
        }
    }

    /*
    =============================
    |          Average          |
    =============================
    Total assertions: 9 (4 avg + 5 gavg)

    Note: I.This average testing including both arithmetic average (avg) and geometric average (gavg).
          II.All geometric average is testing only with both x and y are positive number.

    Assertion 1: avg(x,0) == x/2
        Testing the arithmetic average value of any integer x and 0 should always equal x/2.
    */
    function testAvgZero(int128 x) public {
        // Assertion 1: avg(x,0) == x/2
        try this.avg(x, zero) returns (int128 x0) {
            assert(x0 == x >> 1);
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 2: avg(x,x) == x
        Testing the arithmetic average value of any integer x and x itself should always equal x itself.
    */
    function testAvgX(int128 x) public {
        // Assertion 2: avg(x,x) == x
        try this.avg(x, x) returns (int128 xx) {
            assert(xx == x);
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 3: x <= avg(x,y) <= y || x >= avg(x,y) >= y
        Testing the arithmetic average value of any integer x and y should always be between x and y
        when x != y and both x and y is not 0.
    */
    function testAvgBt(int128 x, int128 y) public {
        require(x != y, "Assuming that x must not be equal to y");
        require(x != 0 && y != 0, "Assuming that both x and y must not be zero");

        // Assertion 3: x <= avg(x,y) <= y || x >= avg(x,y) >= y
        try this.avg(x, y) returns (int128 xy) {
            if (x > y) assert(x >= xy && xy >= y);
            else assert(x <= xy && xy <= y);
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 4: avg(x,y) == avg(y,x)
        Testing the arithmetic average value of any interger x and y should always equal the
        arithmetic average value of any integer y and x as the commutative property of addition.
    */
    function testAvgCommt(int128 x, int128 y) public {
        // Assertion 4: avg(x,y) == avg(y,x)
        try this.avg(x, y) returns (int128 xy) {
            try this.avg(y, x) returns (int128 yx) {
                assert(xy == yx);
            }
            catch {
                // It should not be reverted.
                assert(false);
            }
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 5: gavg(x,0) == 0
        Testing the geometric average value of any integer x and 0 should always yield 0.
    */
    function testGavgZero(int128 x) public {
        require(x >= 0, "Assuming x must be positive number");
        // Assertion 5: gavg(x,0) == 0
        try this.gavg(x, zero) returns (int128 x0) {
            assert(x0 == 0);
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 6: gavg(x,1) == sqrt(x)
        Testing the geometric average value of any interger x and 1 should always equal to square
        root of x
    */
    function testGavgOne(int128 x) public {
        require(x > 0, "Assuming x must be positive number and not 0");
        // Assertion 6: gavg(x,1) == sqrt(x)
        try this.gavg(x, one) returns (int128 x1) {
            try this.sqrt(x) returns (int128 sqx) {
                assert(x1 == sqx);
            }
            catch {
                // It should not be reverted.
                assert(false);
            }
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 7: gavg(x,x) == x
        Testing the geometric average value of any integer x and x itself should always equal to
        x itself.
    */
    function testGavgX(int128 x) public {
        require(x >= 0, "Assuming x must be positive number");
        // Assertion 7: gavg(x,x) == x
        try this.gavg(x, x) returns (int128 xx) {
            assert(xx == x);
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 8: gavg(x,y) == gavg(y,x)
        Testing the geometric average value of any integer x and y should always equal to the
        geometric average value of any integer y and x as the associative property of multiplication.
    */
    function testGavgAssoc(int128 x, int128 y) public {
        require(x >= 0 && y >= 0, "Assuming both x and y must be positive number");
        // Assertion 8: gavg(x,y) == gavg(y,x)
        try this.gavg(x, y) returns (int128 xy) {
            try this.gavg(y , x) returns (int128 yx) {
                assert(xy == yx);
            }
            catch {
                // It should not be reverted.
                assert(false);
            }
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    Assertion 9: x <= gavg(x,y) <= y || x >= gavg(x,y) >= y
        Testing the geometric average value of any integer x and y should always be between x and y
        when x != y. 
    */
    function testGavgBt(int128 x, int128 y) public {
        require(x > 0 && y > 0, "Assuming both x and y are positive numbers and not zero");
        require(x != y, "Assuming x is not equal to y");
        // Assertion 9: x <= gavg(x,y) <= y || x >= gavg(x,y) >= y
        try this.gavg(x, y) returns (int128 xy) {
            if (x > y) assert(x >= xy && xy >= y);
            else assert(x <= xy && xy <= y);
        }
        catch {
            // It should not be reverted.
            assert(false);
        }
    }

    /*
    ===========================
    |          Power          |
    ===========================
    Total assertion: 6

    Assertion 1: x^0 == 1 
        For any integer x to the power of 0 should always yield 1 when x is not 0.
    */
    function testPowZero(int128 x) public {
        require(x != 0, "Assuming x is not zero");
        // Assertion 1: x^0 == 1 
        try this.pow(x, 0) returns (int128 x0) {
            assert(x0 == one);
        }
        catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 2: x^1 == x
        Testing that for any integer x to the power of 1 should equal x itself when x is not 0 and x
        is positive number.
    */
    function testPowOne(int128 x) public {
        require(x > 0, "Assuming x is positive number and not zero");
        // Assertion 2: x^1 == x
        try this.pow(x, 1) returns (int128 x1) {
            assert(x1 == x);
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 3: x^(y+1) == x^(1+y) == x^y * x
        Testing the recurrence relation and associative property. This test requires x to be positive
        number because if y is odd, x^y will be reverted when x is negative, but if y is even, y+1
        will be odd and then x^(y+1) will be reverted.
    */
    function testPowRecur(int128 x, uint y) public {
        require(x > 0 && y != 0, "Assume x and y are not zero, and x is positive number");
        // Assertion 3: x^(y+1) == x^(1+y) == x^y * x
        try this.pow(x, y+1) returns (int128 xy1) {
            try this.pow(x, 1+y) returns (int128 x1y) {
                try this.pow(x, y) returns (int128 xy) {
                    try this.mul(xy, x) returns (int128 xyx) {
                        assert(xy1 == x1y);
                        if (x1y > xyx) xyx++; // handle when mul() is round down
                        assert(x1y == xyx);
                    } catch {
                        // If x^(y+1) passed, this should also pass.
                        assert(false);
                    }
                }
                catch {
                    // If x^(y+1) is not overflow, this should not.
                    assert(false);
                }
            }
            catch {
                // If x^(y+1) passed, this should also pass.
                assert(false);
            }
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 4: x^(y+z) == x^(z+y) ==  x^y * x^z
        Testing like the same as assertion 3 but 1 with any integer z, so if the assertion 3 is pass,
        this assertion should pass as well. This test requires x to be positive number when all the
        power are odd (y+z, y, and z), but x can be negative when all those three are even.
    */
    function testPowMul(int128 x, uint y, uint z) public {
        require(x != 0 && y != 0 && z != 0, "Assuming x, y, and z are not zero");
        // Assertion 4: x^(y+z) == x^(z+y) ==  x^y * x^z
        if ((y+z) % 2 != 0 || y%2 != 0 || z%2 != 0) {
            require(x > 0, "For power odd, x must be positive number");
        }
        try this.pow(x, y+z) returns (int128 xyz) {
            try this.pow(x, z+y) returns (int128 xzy) {
                try this.pow(x, y) returns (int128 xy) {
                    try this.pow(x, z) returns (int128 xz) {
                        try this.mul(xy, xz) returns (int128 xyxz) {
                            assert(xyz == xzy);
                            if (xzy > xyxz) xyxz++; // handle mul() round down
                            assert(xzy == xyxz);
                        }
                        catch {
                            // If x^(y+z) is not overflow, this should not.
                            assert(false);
                        }
                    }
                    catch {
                        // If x^(y+z) is not overflow, then x^z should not overflow because z < y+z
                        assert(false);
                    }
                }
                catch {
                    // If x^(y+z) is not overflow, then x^y should not overflow because y < y+z
                    assert(false);
                }
            }
            catch {
                // If x^(y+z) is not overflow, this should be the same.
                assert(false);
            }
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 5: x^(y-z) == x^y / x^z
        For any integer x to the power of the y-z should be equal to the division of x to the power
        of y and x to the power of z. This test will assume that y always be greater than z, if not,
        swap y -> z and z -> y.
    */
    function testPowDiv(int128 x, uint y, uint z) public {
        require(x != 0 && y != 0 && z != 0, "Assume x, y, and z are not zero");
        require(y != z, "Assume y and z are not equal");
        // Just swap y <-> z to always assume y > z; so y-z will not be reverted.
        uint temp;
        if (y < z) {
            temp = y;
            y = z;
            z = y;
        }
        if ((y-z) % 2 != 0) {
            require(x > 0, "For power odd, x must be positive number");
        }
        // Assertion 5: x^(y-z) == x^y / x^z
        try this.pow(x, y-z) returns (int128 xyz) {
            try this.pow(x, y) returns (int128 xy) {
                try this.pow(x, z) returns (int128 xz) {
                    try this.div(xy, xz) returns (int128 xyxz) {
                            if (xyz > xyxz) xyxz++; //handle div() round down
                            assert(xyz == xyxz);
                    } catch {} // Intentionally left blank, it can be reverted on out-of-range.
                }
                catch {
                    // If x^y is not overflow, then x^z should not overflow because z < y
                    assert(false);
                }
            } catch {} // Intentionally left blank, it can be reverted on overflow.
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }

    /*
    Assertion 6: (x^y)^z == (x^z)^y == x^(y*z) == x^(z*y)
        Testing the associative multiplication property. This test requires x to be positive number
        when all the power are odd (y*z, y, and z), but x can be negative when all those three are even.
    */
    function testPowAssoc(int128 x, uint y, uint z) public {
        require(x != 0 && y != 0 && z != 0, "Assuming x, y, and z are not zero");
        // Assertion 6: (x^y)^z == (x^z)^y == x^(y*z) == x^(z*y)
        uint yz = y * z;
        uint zy = z * y;
        assert(yz == zy); // just for sure
        if ((yz) % 2 != 0 || y%2 != 0 || z%2 != 0) {
            require(x > 0, "For power odd, x must be positive number");
        }
        try this.pow(x, y) returns (int128 xy) {
            try this.pow(xy, z) returns (int128 xy_z) {
                try this.pow(x, z) returns (int128 xz) {
                    try this.pow(xz, y) returns (int128 xz_y) {
                        try this.pow(x, yz) returns (int128 xyz) {
                            try this.pow(x, zy) returns (int128 xzy) {
                                assert(xy_z == xz_y && xz_y == xyz && xyz == xzy);
                            }
                            catch {
                                // If (x^y)^z is not overflow, x^(y*z) should result the same.
                                assert(false);
                            }
                        }
                        catch {
                            // If (x^y)^z is not overflow, x^(y*z) should result the same.
                            assert(false);
                        }
                    }
                    catch {
                        // If (x^y)^z is not overflow, then (x^z)^y should pass, too.
                        assert(false);
                    } 
                }
                catch {
                    // If (x^y)^z is not overflow, then x^z should pass.
                    assert(false);
                }
            } catch {} // Intentionally left blank, it can be reverted on overflow.
        } catch {} // Intentionally left blank, it can be reverted on overflow.
    }
}

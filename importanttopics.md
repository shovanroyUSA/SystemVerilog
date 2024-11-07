# Systemverilog programming varieties topic for quick references

## 1. Delay Operators
- `##n`: Introduces a fixed delay of n clock cycles. For example, `a ##2 b` means that b will be evaluated 2 clock cycles after a is true.
- `##[m:n]`: Specifies a range of delays. For instance, `a ##[3:5] b` means that b can occur between 3 to 5 clock cycles after a.

## 2. Implication Operators
- `|->`: This is the overlapping implication operator. It checks if the right-hand side (RHS) condition holds true from the same cycle when the left-hand side (LHS) condition is true. For example, `a |-> b` means if a is true, then b must also be true in the same cycle.
- `|=>`: This is the non-overlapping implication operator. It checks if the RHS condition holds true one clock cycle after the LHS condition is true. For example, `a |=> b` means if a is true, then b must be true in the next clock cycle.

## 3. Repetition Operators
- `[*n]`: This operator allows you to specify that an expression should repeat continuously for n cycles. For example, `a[*3]` means a should be true for 3 consecutive cycles.
- `[->n]`: Indicates that there should be one or more delay cycles between repetitions. For example, `a[->2]` means a can repeat with at least 2 clock cycles in between.

## 4. Stability and Change Operators
- `$stable(expression)`: Returns true if the value of expression has not changed over the specified time period.
- `$rose(expression)`: Returns true if the least significant bit of expression changed from 0 to 1.
- `$fell(expression)`: Returns true if the least significant bit of expression changed from 1 to 0.

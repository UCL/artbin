# artbin 2.1.3: changes and review notes

This folder holds the changes from **artbin 2.1.2** (19feb2026) to **artbin 2.1.3** (26nov2026), and from **art2bin 1.01** to **art2bin 1.02**.

## Files

| File | Contents |
|---|---|
| `artbin-main/` | The 2.1.3 package (`artbin.ado`, `art2bin.ado`, `artbin.dlg` and the help files) |
| `artbin_213_changes.do` | One short example for each change, with the old and new results in the comments |
| `artbin_213_changes_old.smcl` | Output of the do-file under 2.1.2 |
| `artbin_213_changes_new.smcl` | Output of the do-file under 2.1.3 |

Section and example labels below (A1, B2, C3, ...) refer to `artbin_213_changes.do`.

## Main changes

### 1. New errors for invalid input

These inputs used to give a wrong or missing result. They now stop with an error (section A):

- more `aratios()` than groups (previously n was far too small, e.g. 87 instead of 231);
- `margin()` outside (-1, 1);
- more `doses()` than groups, or doses that are all equal (fewer doses than groups is still allowed, and the last dose is repeated);
- `ccorrect` with `nchi`, which was shown in the table but never applied;
- `nvmethod()` other than 1, 2 or 3 (previously reset to 3 without warning);
- `convcrit()` below 1E-15 (previously only a warning).

A valid `ap2()` now gives a warning that it has no effect.

There are also new errors for cases that previously failed or returned nonsense:

- in `art2bin`, when the event probabilities under H0 cannot be estimated within (0,1);
- in the >2-group search, when the requested power is not reached for n up to 1E9, or the search does not converge.

### 2. Bug fixes that change the sample size or power

Section B:

- For >2 groups, the iterative search could return an n that was too small (104 instead of 111). (B1)
- For >2 groups, power close to 1 showed as missing, and the search went the wrong way (n = 66 instead of 12). (B2)
- For >2 groups, the power approximation isn't valid at very small n, so these cases now give an error. (B3)
- With `condit` or `nchi`, a single allocation ratio is now treated as 1:k. (B4, B5)
- With `ccorrect`, power no longer decreases as n increases at very small n. (B6)
- `art2bin` in power mode: `r(Dart)` with `ccorrect` is fixed. `r(n)`, `r(n0)` and `r(n1)` are now returned, and `r(power)` is now a scalar instead of a local. (B7)
- With `notable`, `r(n)` and `r(power)` are now returned. (B9)

### 3. New option and warnings

Section C:

- `art2bin` now accepts `force`.
- `favourable`/`unfavourable`/`force` and `nvmethod()` now give a warning when they are ignored. Before, `local` or `wald` with >2 groups gave a wrong error.
- The `ngroups()` mismatch check now compares numbers instead of strings.

### 4. Output table only (results unchanged)

Section D:

- The American spellings `favorable`/`unfavorable` are no longer reported as "Inferred by the program".
- Large n (1,000,000 or more), very small probabilities, non-integer ratios and doses are shown without rounding.
- The "(taken as alpha/2 one-sided)" line is now shown for trend/doses, 2-group `nchi` and `condit`. It is deliberately not shown for the >2-group chi-square test, which uses the full alpha.
- `condit` is no longer labelled as a score test.
- "Can not" is now "Cannot".

### 5. Dialog box

Section E:

- There is a new `force` checkbox.
- Switching to "Specify sample size" clears the Power/N box, which is now relabelled "Power or N" and must be filled in.
- The dialog help file has been updated to match.

## What needs review

### New methods

- The normal approximation used in `_nchi2` when `nchi2()` goes out of range (B2).
- The rule that sets the corrected n to 0 when n <= a/2 under `ccorrect` (B6).

### Changes in behaviour

- Is it right to stop with an error at small n (B3: smallest valid n = 9.49) rather than report a result?
- Is a single `aratio(k)` meant to mean 1:k with `condit` or `nchi` (B4, B5)?
- Some commands that ran before now stop with an error (section A). Is that acceptable for existing users' scripts?
- `art2bin`'s `r(power)` is now a scalar. Code using `` `r(power)' `` still works, but please flag any code that treats it as a string.

### Output with `force` (B8)

The table now shows the design that was actually calculated (substantial superiority, H1: pi2 - pi1 > .05). Is that clear enough? The outcome line still says "unfavourable".

### New results to check

- n = 234 (`local`) and n = 207 (`wald`) for `pr(.1 .2 .3)`, which previously gave an error (C3).
- The 4-arm example: n = 111 (B1).
- The power-near-1 example: n = 12 (B2).

### `ap2()`

It has no effect, and it is not in the help file. It now gives a warning at run time. Should we document it as having no effect, or remove it from the syntax?

### Dialog box

Please check it by hand with `db artbin`.

### Documentation

- "What's new" covers the main changes but not yet:
  - the `ccorrect`/`nchi`, `nvmethod()` and `convcrit()` errors;
  - the `ap2()` warning;
  - a single aratio with `nchi`;
  - `art2bin` `force` and its returned results;
  - `r(n)`/`r(power)` with `notable`;
  - the `nvmethod()` warnings.

  Most of these were left out because they involve undocumented options.
- The `ccorrect` section of the help file doesn't mention `nchi`. This was also left out because `nchi` is undocumented.
- Should these be added?

flexsym
=======

Flexsym is an automata-based, Turing-tarpit programming language
for the construction of non-deterministic Turing machines.

## Usage
    $ bin/flexsym &lt;code-file&gt;

test with
    $ rake test

##Description

Just like a Turing machine, the flexsym runtime operates on a set of states, an infinite 1-dimensional tape 
(with each cell initialized to 0), and a head.  Each cell in the tape can hold any Integer 
(that your implementation of Ruby can support...)

Each state can read the value of the tape at the head and branch based on that value.
Additionally, a state can give a set of actions to perform, including increasing/decreasing the value of the
tape at the cell pointed to by the head, moving the head left/right, outputing the value of the cell at the head,
or transition to another state. A state halts the machine if it doesn't transition anywhere. 

If one state has multiple sets of actions for the same value, then machine
branches nondeterminstically, once for each extra set of actions.  Each extra machine gets a copy of the tape
with the same head position. The runtime runs machines in 'steps', where each machine executes the actions
of one state before any transitions are made.  If one machine halts, the program halts.

States are declared by wrapping a string in ';' characters,
and then declaring the default block of commands for that state.

```
    ;state; _ _ _ _
```
They can optionally be followed by a number of branches, each starting with a hex number, 
followed by a block ofcommands

```
    ;state; _ _ _ _ 
    4f      _ _ _ _
```

At runtime, the state will read the value of the tape at the head.
If the value matches the value at the start of one or more branches, those branches will be executed.
Otherwise, the default block will be executed.

There are eight types of commands that can be executed in a block
<table>
    <thead><tr>
        <th>command</th>
        <th>effect</th>
    </tr></thead>
    <tbody>
        <tr>
            <td>+</td>
            <td>Increases the current tape cell value by 1</td>
        </tr>
        <tr>
            <td>-</td>
            <td>Decreases the current tape cell value by 1</td>
        </tr>
        <tr>
            <td>^</td>
            <td>Output the ASCII character with the value of the tape cell at the head</td>
        </tr>
        <tr>
            <td>.</td>
            <td>Output the numeric value of the tape cell pointed to by the head</td>
        </tr>
        <tr>
            <td>&lt;</td>
            <td>Move the tape head left</td>
        </tr>
        <tr>
            <td>&gt;</td>
            <td>Move the tape head right</td>
        </tr>
        <tr>
            <td>_</td>
            <td>Void -- doesn't do anything, takes up one command entry</td>
        </tr>
        <tr>
            <td>;&lt;label&gt;;</td>
            <td>Transition to the state with the given label</td>
        </tr>
    <tbody>
</table>

No matter what order the commands are written in a block, they are executed in the following order:

1. +/-
2. ^/.
3. &gt;/&lt;
4. ;label;

Again, _ are not executed, they just take the place of a command

Many commands of the same type or execution level can be given in a single block, but only the last one
will actually be executed.

See [ examples/hello.flexsym ]( https://github.com/cmaher/flexsym/blob/master/examples/hello.flexsym ) for "Hello, World!"

See [ examples/nd4.flexsym ]( https://github.com/cmaher/flexsym/blob/master/examples/nd4.flexsym ) for nondeterministic branching

Basic Grammar:
```
    <program>       ::= <label> <state-list>
    <label>         ::= ";" [^;]* ";"
    <state-list>    ::= <state> | <state-list> <state>
    <state>         ::= <label> <block> <branch-list>
    <block>         ::= <cmd> <cmd> <cmd> <cmd>
    <cmd>           ::= <op> | <label>
    <op>            ::= "+" | "-" | ">" | "<" | "." | "^" | "_"
    <branch-list>   ::= <branch> | <branch-list> <branch> | ""
    <branch>        ::= <number> <block>
    <number>        ::= <hexnum> | "-" <hexnum>
    <hexnum>        ::= [0-9a-fA-F]+
```
Additionally, non-op, non-';', are allowed anywhere. Note that in most places, a-f will be interpreted as numbers, so be careful.  A good place for comments is inbetween a state's label and its default block


This is an entry for the December 2012 competition at www.pltgames.com

License: MIT
===

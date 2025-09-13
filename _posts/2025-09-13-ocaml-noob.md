---
title: "OCaml noob"
date: 2025-09-13
---
> Just logging for science

# Prerequisites
I am a Java developer and I know how to use git. I have a good command of English, I know how to install Ubuntu, and I am privileged enough to be able to afford a computer to experiment on. That's pretty much it.

I am not a computer nerd in the sense that I really could not care less about the limitations of Java, Spring, Windows, or "using the mouse". I can't be bothered to use command line interfaces and will always prefer clicking on things. I *can* type without looking at the keyboard with all my ten fingers; however I usually use but one finger, and it is *just fine*. I. Don't. Care.

I have little to no experience with functional programming: I hardly learned anything useful on this topic at uni, just did the bare minimum and then forgot everything. What I know about compilers is "oh they parse things". I am also a total web and front-end noob: I can't write css to save my life and I try my best to avoid using Postman in my day-to-day life.

What I do have is some programming experience in a few tech companies. I like asking questions, spending time "modeling" a problem, and then writing code that is easy to read, to test and to maintain. Cherry on top is when it actually makes the problem manageable! I find that people in the same line of work usually wonder about simplicity, efficiency, elegance, and value tools that make problems *look* easy to solve. They talk about about finding good ways to model problems by making up words and implementing new procedures to deal with the code. People read about design patterns and object-oriented programming, but struggle to use them in codebases that are really patchworks of frameworks. Bugs are *expected*. Retro-engineering is mandatory. Nobody knows what they are doing.

What is bugging me is that functional programmers do not seem to have the same conversation topics. They talk about math and sound really satisfied with themselves. How?! How come? I'm curious, hence this experiment. 

Note: I will complain every step of the way. 

# Basic instructions

Here's the goal (the original instructions are actually written on a piece of paper):
1. set up ocaml (1h)
 1.1 linux (ubuntu)
 1.2 opam
 1.3 vscode
 1.4 set up vscode
2. set up yocaml (30min)

## Computer setup

OS  Ubuntu 24.04.3 LTS
IDE Visual Studio Code 1.104.0 (god I hate this)

## Ocaml setup

First I did this and all I got was an ugly camel in the apps menu. Not sure what I'm doing.
`sudo apt install opam`

Then I went here: https://ocaml.org/docs/set-up-editor

What an error! "While the toplevel is great for interactively trying out the language" -what on earth is the "toplevel"?
Okay, let's rewind and instead, I'll read this page: https://ocaml.org/docs/installing-ocaml 

`opam init -y`
A bunch of stuff gets written to the shell.
It says to run
`eval $(opam env --switch=default)`

Okay. Computer didn't catch fire. Let's continue.
How are there 5 tools to install all at once? I would expect something bundled I guess? Anyway:
`opam install ocaml-lsp-server odoc ocamlformat utop`

It took two minutes and now it says that I need additional configuration for my editor. Oh honey, I am not using Emacs or Vim.
The package is called "user-setup". I'll ignore ignore this for now and continue.

Let's check the installation and type `utop`.
LOL everything looks *vintage*. 90's kids unite behind Ocaml utop! It works;;
Why the double semicolon though? I was not prepared for this. Nobody warned me.

Next section is the ["Tour of OCaml"](https://ocaml.org/docs/tour-of-ocaml). Here comes the Universal Toplevel. Oh yes, I am definitely going to read the [introduction](https://ocaml.org/docs/toplevel-introduction) to the OCaml Toplevel. What is this? I'm guessing this has to do with "top-level expressions" but coming from Java, I'm puzzled. 
I'm not sure why and when I would need to evaluate small instructions? For learning? Wow I really don't know anything about the OCaml coding workflow.

Interestingly, the tutorial says "In OCaml, if … then … else … is not a statement; it is an expression." without ever introducing what a statement is. Is this the same as a definition? Since everything has a value, what's the difference? Unclear.

The part about "Unit" is especially surprising. Why is it called that? A unit of what? I'm testing things in Utop while reading. There are lots of very short keywords. I think the OCaml syntax would make more sense to me in context, in a script. I'm faced with examples where I can type anything and it still works, which is not very helpful. Let's stop reading the manual and go back to configuration! 

Ugh, I finally passed the first sentence of the editor set-up guide and now I'm stuck on the second sentence, can you believe this?
"We already installed the tools required to enhance Merlin, our editor of choice with OCaml support." Who is this Merlin? What is happening?
I will prevail. This won't stop me. As instructed, for VSCode, I typed:
`opam install ocaml-lsp-server ocamlformat`
and everything is obviously already installed, because *I* installed it an hour ago. 
I also installed the OCaml Platform extension in VSCode. It comes with a guide. I'm still not sure what to do and I'm tired of reading.
THANK GOD The next page is a tutorial.

I want to write code!! https://ocaml.org/docs/your-first-program
It says it does "breadth-first learning", I'm on board! Let me just clone the repo.
Goddammit WHAT IS AN OPAM SWITCH?! Yet another [introduction page](https://ocaml.org/docs/opam-switch-introduction).
"These switches often cause confusion amongst OCaml newcomers", YOU DON'T SAY. 

`opam switch list` warned me that my environment was not "in sync" with the current switch.
`eval $(opam env)` seemed to do the trick. No idea what I'm doing. 
I really don't care about all this for now, all I want is to create one (1) project. 

Omg this tutorial is not very clear. "We start by setting up a traditional “Hello, World!” project using Dune. Make sure to have installed version 3.12 or later." 3.12 of what? Dune? I guess so. Never used it before, remember! 
`dune --version` is reassuring: it says 3.20.2. There's hope.
`dune init proj hello` is supposed to have created a project?

What if, before continuing, I updated opam, since the tutorial adds a bunch of info about versions and stuff?
I just ran `opam update` and got the weirdest warning: "opam is out-of-date. Please consider updating it (https://opam.ocaml.org/doc/Install.html)". Okay. Yeah that's what I was trying to do? This is not working well o.o Let's visit this other website.
`opam upgrade` says that "everything as up-to-date as possible".
Well my OS is Ubuntu and the best I can get is opam 2.1.5 whereas the latest version is 2.4.1; nevermind, I'll stay out-of-date for now.
I didn't think to choose my OS based on this. The more you know. 

Back to the *hello* project. Okay, let's build! Apparently, you have to be *in* the project to run `dune build`. 
Indeed, `dune exec hello` prints "Hello, World!" to the console. YAY!

Well this took me HOURS. Enough for today. Cheers!


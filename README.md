README
------
* A Lisp (Scheme) interpreter in Ruby; includes a REPL.

* Run directly

``` bash
$ chmod a+x ./lispy.rb  
$ ./lispy.rb
>>> (+ 5 2)
7
```

* Or use *require* 

``` bash
$ irb
ruby-1.9.2-p290 :001 > require './lispy.rb'
 => true 
ruby-1.9.2-p290 :002 > repl ">>> "
>>> (+ 39 3)
42
```

* The interpreter supports basic Scheme syntax

``` lisp
>>> (define r 5)
5
>>> (* 40 r)
200
```

``` lisp
>>> (if (< 10 11) (+ 5 12) (* 19 20))
17
```

``` lisp
>>> (define area (lambda (r) (* 3.141592653 (* r r))))
#<Proc:0x007ff8588342a0@./lispy.rb:77 (lambda)>
>>> (area 51)
8171.282490453
```
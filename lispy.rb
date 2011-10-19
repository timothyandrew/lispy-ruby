#!/usr/bin/env ruby

############################
# Lisp Interpreter in Ruby #
############################

class Env < Hash
    # Environment: a hash of {'var':val} pairs, linked to an outer (scope) Env.
    def initialize(params=[], args=[], outer=nil)
        self.update(Hash[params.zip(args)])
        @outer = outer
    end

    def find(var)
        return self.key?(var) ? self : @outer.find(var)
    end
end

def add_globals(env)

    env.update({'+' => lambda { |x,y| x+y },
                '-' => lambda { |x,y| x-y },
                '*' => lambda { |x,y| x*y },
                '/' => lambda { |x,y| x/y }}
              )

    env.update({'>' => lambda { |x,y| x>y },
                '>=' => lambda { |x,y| x>=y },
                '<' => lambda { |x,y| x<y },
                '<=' => lambda { |x,y| x<=y }}
              )

    # Add the methods from the Math module to the global env. Sqrt, sin, etc...
    math_methods = Math.singleton_methods.map{|x| x.to_s }                   
    env.update(Hash[math_methods.zip(math_methods.map{|x| lambda { |*args| Math.send(x, *args) }})])              

    return env
end
$global_env = add_globals(Env.new)


def evaluate(x, env=$global_env)
    if x.kind_of?(String)           # Variable reference
        return env.find(x)[x]
    elsif not x.kind_of?(Array)     # Literal
        return x
    elsif x[0] == 'quote'           # (quote expression)
        if x.length == 2
            return x[1]
        else
            #Error
        end
    elsif x[0] == 'if'              # (if test conseq alt)
        if x.length == 4
            (_,test,conseq,alt) = x
            return evaluate((evaluate(test,env) ? conseq : alt), env)
        else
            #Error
        end
    elsif x[0] == 'set!'            # (set! var exp)
        if x.length == 3
            (_, var, exp) = x
            env.find(var)[var] = evaluate(exp,env)
        else
            #Error
        end
    elsif x[0] == 'define'          # (define var exp)
        if x.length == 3
            (_, var, exp) = x
            env[var] = evaluate(exp, env)
        else
            #Error
        end
    elsif x[0] == 'lambda'          # (lambda (var*) exp)
        if x.length == 3
            (_, vars, exp) = x
            return lambda { |*args| evaluate(exp, Env.new(vars, args, env))} # Lambda creates a new scope, so we need a new (inner) env
        else
            #Error
        end
    elsif x[0] == 'begin'
        for exp in x[1..-1]
            val = evaluate(exp, env)
        end
        return val
    else
        exps = x.map { |exp| evaluate(exp, env) }
        proc = exps.shift        
        return proc.call(*exps)
    end
end

def read(str)
    return read_from(tokenize(str))
end

def read_from(tokens)
    if tokens.length == 0
        # Error
    end
    token = tokens.shift
    if token == ')'
        # Error - Can't have ')' without '('
    elsif token == '('
        exp = []
        while tokens[0] != ')'
            exp.push(read_from(tokens))
        end
        tokens.shift # Remove the ')'
        return exp
    else
        return atom token
    end
end

# Convert numbers to numbers. Everything else is a Symbol
def atom(token)
    begin
        return Integer(token)
    rescue ArgumentError
        begin
            return Float(token)
        rescue ArgumentError
            return String(token)
        end
    end
end

def tokenize(str)
    return str.gsub("(", " ( ").gsub(")", " ) ").split
end

def repl(prompt='> ')
    # Read - eval - print - loop
    while true
        print prompt
        val = evaluate(read(gets()))
        puts val if val
    end
end

if __FILE__ == $0
  repl ">>> "
end

    
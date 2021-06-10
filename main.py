#!/usr/bin/env python

def fib(n):
    """
    Fibonacci func

    :param n: number: number of sequences to generate
    """
    if n <= 1:
        return n
    return fib(n - 2) + fib(n - 1)


def factorial(n):
    if n <= 1:
        return n
    return n * factorial(n - 1)


# 0 1 1 2 3 5
print(fib(6))
print(factorial(5))
print('Hello')


def dada(name):
    print("My dada's name is {}.".format(name))


dada("ax")

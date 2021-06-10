const username = "Mr. Name";

function salutation(name: string): string {
  return `Yo, ${name}`;
}

// TODO: I just can wait
console.log(salutation("Axl"));

const fib = (n: number) => {
  if (n <= 2) return 1;
  return fib(n - 1) + fib(n - 2);
};

const factorial = (n: number) => {
  if (n <= 2) return n;
  return n * factorial(n - 1);
};

console.log("Fib");
for (let i = 1; i < 10; i++) {
  console.log(i, fib(i));
}

console.log("Factorial");
for (let i = 1; i < 10; i++) {
  console.log(i, factorial(i));
}

console.log("lower");

const watchList = ["bitcoin", "ethereum", "ripple", "dogecoin"];

watchList.forEach((w): void => console.log(w));

const n = {};

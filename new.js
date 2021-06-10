const username = "Mr. Name";

const salutation = (name) => {
  return `Yo, ${name}`;
};

console.log(salutation("Axl"));

function fib(n) {
  if (n <= 2) return 1;
  return fib(n - 1) + fib(n - 2);
}

const factorial = (n) => {
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

watchList.forEach((w) => console.log(w));

const n = {};

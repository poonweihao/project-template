import { expect, test } from "vitest";
import { add } from "../src/index.js";

test("add", () => {
  expect(add(2, 3)).toBe(5);
});

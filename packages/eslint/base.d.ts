declare module "@lattica/eslint/base" {
  import type { Linter } from "eslint";
  export const config: Linter.Config;
  export default config;
}

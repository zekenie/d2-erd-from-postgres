## [D2](https://github.com/terrastruct/d2#related) ERD from Postgres

![Example](/./example.png)

[D2](https://github.com/terrastruct/d2) Diagrams are awesome. If you have a postgres database that already exists that you'd like to diagram, you can use this tool to generate an ERD.

## Installation

- Clone this repo
- `npm install`

## Usage

```sh
$ node index postgres://postgres:postgres@localhost:5432/yourdb
```

You will see that there are 2 gitignored files generated, `out.svg` and `output.d2`.

Happy hacking!

#!/usr/bin/env python3
import argparse, sys
import prestodb
import requests

def run_query(host, sql, port=8080, catalog="hive", schema="nyc"):
    conn = prestodb.dbapi.connect(
        host=host,
        port=port,
        user="poc-user",
        catalog=catalog,
        schema=schema,
        http_scheme="http",
    )
    cur = conn.cursor()
    cur.execute(sql)
    rows = cur.fetchall()
    for r in rows:
        print(*r, sep="\t")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--host", required=True)
    p.add_argument("--sql", required=True)
    p.add_argument("--port", type=int, default=8080)
    p.add_argument("--catalog", default="hive")
    p.add_argument("--schema", default="products")
    args = p.parse_args()
    run_query(args.host, args.sql, args.port, args.catalog, args.schema)

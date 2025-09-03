# 1. Introdução (30s)

### O que é o PrestoDB?

* Um motor de consultas SQL distribuído.

* Criado pelo Facebook em 2012 para lidar com grandes volumes de dados.

Open source, hoje mantido pela Presto Foundation.

# 2. Problema que resolve (1 min)

* Antes: consultas em Big Data demoravam muito (Hadoop/MapReduce).

* Presto: consultas interativas, rápidas e com SQL padrão.

* Conecta em várias fontes de dados sem precisar mover tudo.

# 3. Como funciona (1 min 30s)

### Arquitetura:

* Coordinator → recebe a query, distribui o plano de execução.

* Workers → executam partes da query em paralelo.

* Conectores → acessa dados em diferentes sistemas:

* Hive, Kafka, MySQL, PostgreSQL, Cassandra, etc.

* Tudo via ANSI SQL → curva de aprendizado baixa.

# 4. Benefícios principais (1 min)

### Performance → baixa latência para grandes volumes.

* Flexibilidade → acessa múltiplas fontes de dados em uma única query.

* Escalabilidade → adiciona workers conforme a demanda.

* Comunidade ativa (Facebook, Uber, Airbnb, Netflix usam).

# 5. Casos de uso (1 min)

* Análises interativas em Data Lakes.

* Unificação de dados (consultar MySQL + S3 + Kafka numa só query).

* Exploração ad-hoc sem pré-processar tudo.

* Dashboards e BI conectados diretamente ao Presto.

# 6. Conclusão (30s)

* PrestoDB = SQL + Big Data + Velocidade.

* Ideal para empresas que precisam analisar dados massivos em tempo real.

* É uma ponte entre SQL tradicional e o ecossistema de Big Data.


# To Do 

* Traduzir e demonstracao de codigo e demo
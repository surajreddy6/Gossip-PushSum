# Gossip Network Simulator
Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the type of Gossip implemented can be referred to as Asynchronous Gossip.


## What is working (Algorithms and Topologies included):

### Gossip:

* Full
* 3D
* Random2D
* Imperfect 2D
* Sphere
* Line

### Push-sum:

* Full
* 3D
* Random2D
* Imperfect 2D
* Sphere
* Line

#### Running GOSSIP

```
$ mix run proj2.exs 100 full gossip
$ mix run proj2.exs 100 imp2D gossip
$ mix run proj2.exs 100 sphere gossip
$ mix run proj2.exs 100 rand2D gossip
$ mix run proj2.exs 100 d3 gossip
$ mix run proj2.exs 100 line gossip
```

#### Running PushSum

```
$ mix run proj2.exs 100 full pushsum
$ mix run proj2.exs 100 imp2D pushsum
$ mix run proj2.exs 100 sphere pushsum
$ mix run proj2.exs 100 rand2D pushsum
$ mix run proj2.exs 100 d3 pushsum
$ mix run proj2.exs 100 line pushsum
```

#### Running GOSSIP for failure nodes

```
$ mix run proj2_failure.exs 100 full gossip
$ mix run proj2_failure.exs 100 imp2D gossip
$ mix run proj2_failure.exs 100 sphere gossip
$ mix run proj2_failure.exs 100 rand2D gossip
$ mix run proj2_failure.exs 100 d3 gossip
$ mix run proj2_failure.exs 100 line gossip
```

#### Running PushSum for failure nodes

```
$ mix run proj2_failure.exs 100 full pushsum
$ mix run proj2_failure.exs 100 imp2D pushsum
$ mix run proj2_failure.exs 100 sphere pushsum
$ mix run proj2_failure.exs 100 rand2D pushsum
$ mix run proj2_failure.exs 100 d3 pushsum
$ mix run proj2_failure.exs 100 line pushsum
```

Gossip

* Full - 7700
* 3D - 50,000
* Random2D - 10,000
* Imperfect 2D - 40,000
* Sphere - 70,000
* Line - 150

Push-sum

* Full - 7700
* 3D - 4000
* Random2D - 10,000
* Imperfect 2D - 10,000
* Sphere - 10,000
* Line - 800





## Authors

* **Aditi Malladi UFID: 9828-6321**
* **Suraj Kumar Reddy Thanugundla UFID: 3100-9916**




# Gossip Network Simulator
Gossip type algorithms can be used both for group communication and for aggregate computation. The goal of this project is to determine the convergence of such algorithms through a simulator based on actors written in Elixir. Since actors in Elixir are fully asynchronous, the particular type of Gossip implemented is the so called Asynchronous Gossip.


## Algorithms and Topologies included:

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
$ mix run proj2.exs 1000 sphere gossip
```

#### Running PushSum

```
$ mix run proj2.exs 1000 rand2D pushsum
```

#### Running GOSSIP for failure nodes

```
$ mix run proj2_failure.exs 1000 rand2D gossip
```

Gossip

1. Line  -  512
2. Full Network - 100000
3. Grid - 100000
4. Imperfect Grid - 100000

Push-sum

1. Line - 256
2. Full Network -1024
3. Grid - 4096
4. Imperfect Grid – 4096




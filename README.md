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

#### Running PushSum for failure nodes

```
$ mix run proj2_failure.exs 1000 rand2D pushsum
```

Gossip

* Full - 7700
* 3D - 
* Random2D -
* Imperfect 2D -
* Sphere - 
* Line - 150

Push-sum

* Full - 7700
* 3D - 
* Random2D -
* Imperfect 2D -
* Sphere - 
* Line - 150





## Authors

* **Aditi Malladi UFID: 9828-6321**
* **Suraj Kumar Reddy Thanugundla UFID: 3100-9916**




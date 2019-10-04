part of 'repos_bloc.dart';

@immutable
abstract class ReposState {}

class InitialReposState extends ReposState {}

class LoadingReposState extends ReposState {}

class LoadedReposState extends ReposState {
  final List<Repo> repos;

  LoadedReposState(this.repos);
}

class AllReposLoadedState extends ReposState {
}
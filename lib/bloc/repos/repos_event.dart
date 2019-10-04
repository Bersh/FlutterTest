part of 'repos_bloc.dart';

@immutable
abstract class ReposEvent {}


class LoadReposEvent extends ReposEvent {}

class ReloadReposEvent extends ReposEvent {}
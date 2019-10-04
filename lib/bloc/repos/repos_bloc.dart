import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_app/model/repo.dart';
import 'package:flutter_app/repo/repository.dart';
import 'package:meta/meta.dart';

part 'repos_event.dart';

part 'repos_state.dart';

class ReposBloc extends Bloc<ReposEvent, ReposState> {
  Repository _repository;

  @override
  ReposState get initialState => InitialReposState();

  @override
  Stream<ReposState> mapEventToState(ReposEvent event) async* {
    if (event is LoadReposEvent) {
      yield LoadingReposState();
      List<Repo> repos = await _repository.getRepos();
      if (repos.isEmpty) {
        yield AllReposLoadedState();
      } else {
        yield LoadedReposState(repos);
      }
    } else if (event is ReloadReposEvent) {
      yield LoadingReposState();
      List<Repo> repos = await _repository.reload();
      if (repos.isEmpty) {
        yield AllReposLoadedState();
      } else {
        yield LoadedReposState(repos);
      }
    }
  }
}

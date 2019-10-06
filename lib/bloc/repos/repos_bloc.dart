import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_app/model/repo.dart';
import 'package:flutter_app/repo/repository.dart';
import 'package:meta/meta.dart';

part 'repos_event.dart';

part 'repos_state.dart';

class ReposBloc extends Bloc<ReposEvent, ReposState> {
  Repository _repository = Repository();
  bool _isLoading = false;

  @override
  ReposState get initialState => InitialReposState();

  @override
  Stream<ReposState> mapEventToState(ReposEvent event) async* {
    if (event is LoadReposEvent && !_isLoading) {
      _isLoading = true;
      try {
        yield LoadingReposState();
        List<Repo> repos = await _repository.getRepos();
        if (repos.isEmpty) {
          yield AllReposLoadedState();
        } else {
          yield LoadedReposState(repos);
        }
      } finally {
        _isLoading = false;
      }
    } else if (event is ReloadReposEvent) {
      _isLoading = true;
      try {
        yield LoadingReposState();
        List<Repo> repos = await _repository.reload();
        if (repos.isEmpty) {
          yield AllReposLoadedState();
        } else {
          yield LoadedReposState(repos);
        }
      } finally {
        _isLoading = false;
      }
    }
  }
}

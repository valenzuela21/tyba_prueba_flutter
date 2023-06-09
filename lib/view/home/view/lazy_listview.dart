import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marvel/core/components/button_related/button_style.dart';
import 'package:marvel/core/constants/app_constants.dart';
import '../../../core/components/dialog/error_dialog.dart';
import '../../../core/components/modal_custombtn.dart';
import '../../../core/extension/context_extensions.dart';
import '../../../view/detail/viewmodel/detail_viewmodel.dart';
import '../../../view/home/cubit/home_cubit.dart';

class LazyListView extends StatefulWidget {
  const LazyListView({
    Key? key,
  }) : super(key: key);

  @override
  State<LazyListView> createState() => _LazyListViewState();
}

class _LazyListViewState extends State<LazyListView> {
  late DetailViewmodel detailViewmodel;
  final scrollController = ScrollController();
  final TextEditingController textControllerSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    detailViewmodel = DetailViewmodel();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    textControllerSearch.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      if (context.read<HomeCubit>().hasNext) {
        context.read<HomeCubit>().fetchNextCharacters(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          ErrorExtension(
            ErrorDialog(errorMessage: state.message),
          ).show(context);
        }
      },
      builder: (context, state) {
        GlobalKey<FormState> formKey = GlobalKey<FormState>();

        if (state is HomeInitial) {
          context.read<HomeCubit>().fetchNextCharacters(context);
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is HomeError) {
          return ErrorDialog(errorMessage: state.message);
        } else {
          return Column(
            children: [
              ModalCustomButton(
                  children: SizedBox(
                height: 150,
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: textControllerSearch,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppConstants.insertText;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          //print('Result: ' + textControllerSearch.text);
                          context
                              .read<HomeCubit>()
                              .findNextCharacter(textControllerSearch.text.toLowerCase());
                          Navigator.of(context).pop();
                        },
                        child: Text(AppConstants.searchText),
                        style: buttonStyle(context),
                      )
                    ],
                  ),
                ),
              )),
              state is HomeFilter ?
              Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: context.paddingLowHorizontal,
                    children: [
                      ...context.read<HomeCubit>().characterFilter.map(
                            (character) => GestureDetector(
                          onTap: () => context
                              .read<HomeCubit>()
                              .navigateToDetailView(character, detailViewmodel),
                          child: ListTile(
                            title: Text(character.name!),
                            leading: CircleAvatar(
                              backgroundImage:
                              NetworkImage(character.photoURL!),
                            ),
                          ),
                        ),
                      )
                          .toList(),
                      if (context.read<HomeCubit>().hasNext)
                        const Center(
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  )):
              Expanded(
                  child: ListView(
                controller: scrollController,
                padding: context.paddingLowHorizontal,
                children: [
                  ...context
                      .read<HomeCubit>()
                      .characters
                      .map(
                        (character) => GestureDetector(
                          onTap: () => context
                              .read<HomeCubit>()
                              .navigateToDetailView(character, detailViewmodel),
                          child: ListTile(
                            title: Text(character.name!),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(character.photoURL!),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  if (context.read<HomeCubit>().hasNext)
                    const Center(
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              )),
            ],
          );
        }
      },
    );
  }
}

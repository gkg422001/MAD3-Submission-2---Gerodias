import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:state_change_demo/src/models/post.model.dart';
import 'package:state_change_demo/src/models/user.model.dart';

class RestDemoScreen extends StatefulWidget {
  const RestDemoScreen({super.key});

  @override
  State<RestDemoScreen> createState() => _RestDemoScreenState();
}

class _RestDemoScreenState extends State<RestDemoScreen> {
  PostController controller = PostController();
  UserController userCont = UserController();
  TextEditingController bodyC = TextEditingController(),
      titleC = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.getPosts();
    userCont.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        leading: IconButton(
            onPressed: () {
              controller.getPosts();
            },
            icon: const Icon(Icons.refresh)),
        actions: [
          IconButton(
              onPressed: () {
                showNewPostFunction(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.error != null) {
                return Center(
                  child: Text(controller.error.toString()),
                );
              }
              if (!controller.working && !userCont.working) {
                return Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (Post post in controller.postList)
                            GestureDetector(
                              onTap: () {
                                PostDetails(context, post.id);
                              },
                              child: Container(
                                height: 150,
                                width: 300,
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          userCont
                                              .userList[post.userId - 1].name,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.italic),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                            onPressed: () {
                                              EditPost(context, post);
                                            },
                                            icon: const Icon(Icons.edit)),
                                        DeleteButton(
                                            controller: controller, post: post)
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                        ],
                      )),
                );
              }
              return const Center(
                child: SpinKitChasingDots(
                  size: 54,
                  color: Colors.black87,
                ),
              );
            }),
      ),
    );
  }

  Future<dynamic> EditPost(BuildContext context, Post post) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          title: const Text("Edit post"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (titleC.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 76, 76, 76),
                        content: const Text(
                          "Title is empty",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Close',
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      );
                    },
                  );
                } else if (bodyC.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 76, 76, 76),
                        content: const Text(
                          "Content is empty",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Close',
                                style: TextStyle(color: Colors.white),
                              ))
                        ],
                      );
                    },
                  );
                } else {
                  await controller.updatePost(
                      title: titleC.text.trim(),
                      body: bodyC.text.trim(),
                      postID: post.id,
                      userID: post.userId);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text("Edit"),
            )
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Title"),
              Flexible(
                child: TextFormField(
                  controller: titleC,
                ),
              ),
              const Text("Content"),
              Flexible(
                child: TextFormField(
                  controller: bodyC,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> PostDetails(BuildContext context, int postID) {
    Post specificPost = controller.getPostById(postID);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      "Title: ${specificPost.title}",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                  child: Text(
                    "Content:",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                  child: Text(
                    specificPost.body,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                  child: Text(
                    "--${userCont.userList[specificPost.userId - 1].name}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Text(
                    userCont.userList[specificPost.userId].phone,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Text(
                    userCont.userList[specificPost.userId - 1].email,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showNewPostFunction(BuildContext context) {
    AddPostDialog.show(context, controller: controller);
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.controller,
    required this.post,
  });

  final PostController controller;
  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  'Confimartion Message',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                content: const Text(
                  'Do you want to delete this post?',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        await controller.deletePost(postID: post.id);
                        // Navigator.pop(context);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        "Yes",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "No",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.delete));
  }
}

class AddPostDialog extends StatefulWidget {
  static show(BuildContext context, {required PostController controller}) =>
      showDialog(
          context: context, builder: (dContext) => AddPostDialog(controller));
  const AddPostDialog(this.controller, {super.key});

  final PostController controller;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late TextEditingController bodyC, titleC;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController();
    titleC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text("Add new post"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (titleC.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 76, 76, 76),
                    content: const Text(
                      "Title is empty",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  );
                },
              );
            } else if (bodyC.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color.fromARGB(255, 76, 76, 76),
                    content: const Text(
                      "Content is empty",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  );
                },
              );
            } else {
              widget.controller.makePost(
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: 1);
              Navigator.of(context).pop();
            }
          },
          child: const Text("Add"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title"),
          Flexible(
            child: TextFormField(
              controller: titleC,
            ),
          ),
          const Text("Content"),
          Flexible(
            child: TextFormField(
              controller: bodyC,
            ),
          ),
        ],
      ),
    );
  }
}

class PostController with ChangeNotifier {
  Map<String, dynamic> posts = {};
  bool working = true;
  Object? error;

  List<Post> get postList => posts.values.whereType<Post>().toList();

  clear() {
    error = null;
    posts = {};
    notifyListeners();
  }

  Future<Post> makePost(
      {required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      print(title);
      print(body);
      print(userId);
      http.Response res = await HttpService.post(
          url: "https://jsonplaceholder.typicode.com/posts",
          body: {"title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      print(res.body);

      Map<String, dynamic> result = jsonDecode(res.body);

      Post output = Post.fromJson(result);
      posts[output.id.toString()] = output;
      working = false;
      notifyListeners();
      return output;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<Post> tmpPost = result.map((e) => Post.fromJson(e)).toList();
      posts = {for (Post p in tmpPost) "${p.id}": p};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Post getPostById(int postID) {
    return posts[postID.toString()];
  }

  Future<void> getSpecificPost({required int postID}) async {
    try {
      working = true;
      clear();
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts/$postID");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      var result = jsonDecode(res.body);
      List<Post> tmpPost = [Post.fromJson(result)];
      posts = {for (Post p in tmpPost) "${p.id}": p};

      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> deletePost({required int postID}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.delete(
          url: "https://jsonplaceholder.typicode.com/posts/1",
          body: {"id": postID});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      print(res.body);

      posts.remove(postID.toString());
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(
      {required int postID,
      required String title,
      required String body,
      required int userID}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.put(
          url: "https://jsonplaceholder.typicode.com/posts/$postID",
          body: {"body": body, "title": title, "userId": userID});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      posts[postID.toString()] =
          Post(userId: userID, id: postID, title: title, body: body);
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }
}

class UserController with ChangeNotifier {
  Map<String, dynamic> users = {};
  bool working = true;
  Object? error;

  List<User> get userList => users.values.whereType<User>().toList();

  getUsers() async {
    try {
      working = true;
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/users");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<User> tmpUser = result.map((e) => User.fromJson(e)).toList();
      users = {for (User u in tmpUser) "${u.id}": u};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  clear() {
    users = {};
    notifyListeners();
  }
}

class HttpService {
  static Future<http.Response> get(
      {required String url, Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> post(
      {required String url,
      required Map<dynamic, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> delete(
      {required String url,
      required Map<dynamic, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.delete(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }

  static Future<http.Response> put(
      {required String url,
      required Map<dynamic, dynamic> body,
      Map<String, dynamic>? headers}) async {
    Uri uri = Uri.parse(url);
    return http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
      if (headers != null) ...headers
    });
  }
}

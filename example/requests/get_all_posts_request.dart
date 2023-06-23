import '../models/post.dart';
import 'base_request.dart';

class GetAllPostsRequest extends TestBaseRequest<List<Post>> {
  GetAllPostsRequest()
      : super(
          url: '/posts',
        );

  @override
  List<Post> getModelFromJson(json) {
    return json['posts'].map<Post>((post) => Post.fromJson(post)).toList();
  }
}

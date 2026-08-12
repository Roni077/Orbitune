import 'package:fpdart/fpdart.dart';
import '../errors/failure.dart';

typedef Result<T> = Either<Failure, T>;

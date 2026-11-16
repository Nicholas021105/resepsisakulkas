import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../screenshot_test/helper_foto.dart';

/// Penulisan screenshot yang tahan terhadap berkas terkunci sesaat (Windows
/// errno 1224 saat PNG sedang dipetakan proses lain). Inilah penyebab
/// screenshot test dulu sesekali gagal.
void main() {
  final berkas = File('tidak-ditulis-sungguhan.png');
  const terkunci = FileSystemException(
    'Cannot open file',
    'x.png',
    OSError('user-mapped section open', 1224),
  );

  test('berhasil pada percobaan pertama: ditulis sekali', () async {
    var panggilan = 0;
    await tulisDenganUlang(berkas, [1, 2, 3], tulis: (_, _) => panggilan++);
    expect(panggilan, 1);
  });

  test('terkunci sesaat: dicoba lagi sampai berhasil', () async {
    var panggilan = 0;
    List<int>? tertulis;
    await tulisDenganUlang(
      berkas,
      [7, 8],
      jeda: Duration.zero,
      tulis: (_, isi) {
        if (++panggilan < 4) throw terkunci;
        tertulis = isi;
      },
    );
    expect(panggilan, 4);
    expect(tertulis, [7, 8]);
  });

  test('tetap terkunci: menyerah dengan pesan yang jelas', () async {
    var panggilan = 0;
    await expectLater(
      tulisDenganUlang(
        berkas,
        [1],
        maksCoba: 3,
        jeda: Duration.zero,
        tulis: (_, _) {
          panggilan++;
          throw terkunci;
        },
      ),
      throwsA(
        isA<FileSystemException>()
            .having((e) => e.message, 'pesan', contains('3 kali'))
            .having((e) => e.osError?.errorCode, 'errno', 1224),
      ),
    );
    expect(panggilan, 3);
  });

  test('galat selain FileSystemException tidak ditelan', () async {
    await expectLater(
      tulisDenganUlang(berkas, [1], tulis: (_, _) => throw StateError('lain')),
      throwsStateError,
    );
  });
}

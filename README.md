# ImageSearch

# 구성 및 동작
앱은 두개의 화면으로 되어있고, 탭바 컨트롤러로 이동한다. 홈화면에서는 search bar를 이용해 이미지를 검색할 수 있다. 사용자가 검색할 이미지를 텍스트로 입력하면,
Google Search API를 사용하여 네트워크로 부터 해당 이미지 url을 받아온 후에 테이블뷰에 뛰운다. 테입블 뷰에서는 이미지를 선택해 디스크에 저장할 수 있으며, 저장된 이미지 화면에서는
디스크에 저장된 이미지들을 테이블뷰 형태로 나열해 보여주고 원하는 이미지를 검색할 수도 있고 삭제할 수도 있다.

# 공부한것(앱의 핵심요소)
1. URLSession으로 dataTask를 구성하여 서버로부터 이미지들의 url이 있는 json 파일 받아오기
2. 받아온 json파일을 decoding하여 url의 Array형태로 바꾸기
3. Array 형태로 된 url들을 dataTask로 구성하여 서버로 부터 이미지 받아와서 UIImage() 형태로 만들기
4. table view cell 구성시에, 이미지의 너비를 고정시키고(content view bounds width - 40), 비율에 맞게 높이를 계산하여 이미지의 높이 제약조건을 설정하여 이미지의 크기에 따라 cell의 높이가 동적으로 조정되도록 하기
6. table view를 구성할 때, 모든 이미지를 처음부터 다 받아와서 구성하는 것이 아니고, 처음에 visible한 영역만 가져오고 나머지는 prefetching data source 사용해서 미리 받아오기
7. table view의 cell에서 버튼을 클릭하면 디스크에 해당 cell이 가진 이미지 파일 추가하기
8. 저장된 이미지 화면에서는 디스크로 부터 이미지 파일을 받아와서 table view에 뿌려주기 
9. 저장된 이미지 화면에서 search controller를 이용해서 이미지를 검색할 수 있도록 하기

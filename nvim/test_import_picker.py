# Test file for Python Import Picker
# 이 파일로 import picker 기능을 테스트해보세요

def test_function():
    # 아래 함수들에 커서를 올리고 <leader>pi 또는 <leader>I 를 눌러보세요
    
    # requests 라이브러리 테스트
    get()  # 이 함수에 커서를 올리고 import picker 실행
    post()
    
    # numpy 테스트  
    array()
    zeros()
    
    # pandas 테스트
    DataFrame()
    read_csv()
    
    # 표준 라이브러리 테스트
    loads()  # json
    dumps()
    sleep()  # time
    
    # datetime 테스트
    datetime()
    
    # pathlib 테스트
    Path()
    
    # os 테스트
    path.join()
    
    # 없는 함수 (커스텀 입력 테스트)
    unknown_function()

# Insert 모드에서도 테스트해보세요
# 함수명 작성 후 <C-i> 키 조합 사용

if __name__ == "__main__":
    test_function()
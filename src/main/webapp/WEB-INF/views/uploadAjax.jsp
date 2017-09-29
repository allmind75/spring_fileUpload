<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<style>
	.fileDrop {width: 100%; height: 200px; border: 1px dotted blue;}
	small {margin-left: 3px; font-weight: bold; color: gray;}
</style>
</head>
<body>
	<h3>Ajax File Upload</h3>
	<div class="fileDrop"></div>
	
	<div class="uploadedList"></div>
	
	
	<!-- 스마트폰에서 사진 찍어서 서버로 전송-->
	<form method="post" enctype="multipart/from-data" action="uploadFile"> 
		<input type="file" id="camera" name="file" capture="camera" accept="image/*" />
		<input type="submit" value="전송">
	</form>

   
    
    
	<script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
	<script>
		$(".fileDrop").on("dragenter dragover", function(envet) {
			event.preventDefault();
		});
		
		$(".fileDrop").on("drop", function(event){
			event.preventDefault();
			
			/*
			event.originalEvent : jQuery를 이용하는 경우 event가 순수한 DOM 이벤트가 아니기 때문에
			순수한 원래의 DOM 이벤트를 가져옴
			
			dataTransfer : 이벤트와 깉이 전달된 데이터를 의미
			dataTransfer.files : 그 안에 포함된 파일 데이터 찾음
			*/
			var files = event.originalEvent.dataTransfer.files;
			var file = files[0];
			
			//console.log(file);
			
			//HTML5에서 지원하는 FormData 객체를 이용해서 <form>태그로 만든 데이터의 전송 방식과 동일하게 파일데이터 전송 가능
			var formData = new FormData();
			
			formData.append("file", file);
			
			
			/*
			jQuery의 $.ajax()를 이용해서 FormData 객체에 있는 파일 데이터를 전송하기 위해서는
			processData와 contentType 옵션을 반드시 false로 지정해야함
			
			processData : 데이터를 일반저그올 query string으로 변환할 것인지를 결정
			기본값은 true, 'application/x-www-form-urlencoded'타입을 전송
			다른 형식으로 데이터를 보내기 위하여 자동 변환하고 싶지 않은 경우는 false를 지정
			
			contentType : 기본ㄱ밧은 'application / x-www-form-urlencoded'
			파일의 경우 multipart/form-data 방식으로 전송하기 위해서 false로 지정
			*/
			$.ajax({
				url: '/uploadAjax',
				data: formData,
				dataType: 'text',
				processData: false,
				contentType: false,
				type: 'POST',
				success: function(data) {
					
					//alert(data);
					
					var str = "";
					
					if(checkImageType(data)) {
						str = "<div>" + "<a href='displayFile?fileName=" + getImageLink(data) + "'>" + 
						"<img src='displayFile?fileName=" + data + "'>"
						+ "</a><small data-src=" + data + ">X</small></div>";
					} else {
						str = "<div><a href='displayFile?fileName=" + data + "'>" + getOriginalName(data)
						+ "</a><small data-src=" + data + ">X</small></div>";
					}
					
					$(".uploadedList").append(str);
					
				}
			});
		});
		
		function checkImageType(fileName) {
			var pattern = /jpg|gif|png|jpeg/i;	//i : 대소문자 구분 없음
			return fileName.match(pattern);
		}
		
		function getOriginalName(fileName) {
			
			if(checkImageType(fileName)) {
				return;
			}
			
			var idx = fileName.indexOf("_") + 1;
			return fileName.substr(idx);
		}
		
		function getImageLink(fileName) {
			
			if(!checkImageType(fileName)) {
				return;
			}
			var path = fileName.substr(0,12);
			var name = fileName.substr(14);

			return path + name;
		}
		
		$(".uploadedList").on("click", "small", function(event){
			
			var that = $(this);
			console.log("delete");
			console.log($(this).attr("data-src"));
			$.ajax({
				url: "deleteFile",
				type: "post",
				data: {fileName:$(this).attr("data-src")},
				dataType: "text",
				success: function(result) {
					if(result == 'deleted') {
						//화면에 표시된 div 제거
						that.parent("div").remove();
					}
				}
			})
		});
		
        $('#camera').change(function(e) {
        	
        	var imgFile = URL.createObjectURL(e.target.files[0]);	//파일 이름
        	var file = e.target.files[0];			//파일 가져오기
			var formData = new FormData();
			formData.append("file", file);
			
			$.ajax({
				url: '/uploadFile',
				data: formData,
				dataType: 'text',
				processData: false,
				contentType: false,
				type: 'POST',
				success: function(data) {
					  
					/*
					var str = "";
					if(checkImageType(data)) {
						str = "<div>" + "<a href='displayFile?fileName=" + getImageLink(data) + "'>" + 
						"<img src='displayFile?fileName=" + data + "'>"
						+ "</a><small data-src=" + data + ">X</small></div>";
					} else {
						str = "<div><a href='displayFile?fileName=" + data + "'>" + getOriginalName(data)
						+ "</a><small data-src=" + data + ">X</small></div>";
					}					
					$(".uploadedList").append(str);
					*/
					var jsonData = JSON.parse(data);
					var jsonObject = jsonData.faces[0];
					
					console.log(jsonObject.gender.value);
					console.log(jsonObject.gender.confidence);
					
					console.log(jsonObject.age.value);
					console.log(jsonObject.age.confidence);
					
					console.log(jsonObject.emotion.value);
					console.log(jsonObject.emotion.confidence);
					
				}
			});
        });
        
        $(document).ready(function() {
            if (!('url' in window) && ('webkitURL' in window)) {
                window.URL = window.webkitURL;
            }
        });
	</script>
</body>
</html>
⏺ Chat API 연동 문서                                                                                                                    
                                                                                                                                        
  현재 Chat API는 두 가지 독립된 채팅 시스템으로 구성되어 있습니다.                                                                     
                                                                                                                                        
  ---                                                                                                                                   
  시스템 구분                                                                                                                           
  ┌──────────────┬─────────────────────────┬───────────────────┬───────────────────────┐                                                
  │    시스템    │           API           │       모델        │         용도          │                                                
  ├──────────────┼─────────────────────────┼───────────────────┼───────────────────────┤                                                
  │ 채팅방 기반  │ make_room, send_message │ ChatRoom, ChatLog │ 세션 관리 + 카드 추천 │                                                
  ├──────────────┼─────────────────────────┼───────────────────┼───────────────────────┤                                                
  │ AI 직접 대화 │ GET /chat/, POST /chat/ │ ChatMessage       │ Gemini AI 금융 상담   │                                                
  └──────────────┴─────────────────────────┴───────────────────┴───────────────────────┘                                                 
  모든 API는 JWT 인증 필수입니다.                                                                                                       
  Authorization: Bearer <access_token>                                                                                                  
                                                                                                                                        
  ---                                                                                                                                   
  1. POST /api/v1/chat/make_room/ — 채팅방 생성                                                                                         
                                                                                                                                        
  채팅방을 생성하고 세션 ID를 발급받습니다. send_message를 사용하려면 반드시 먼저 호출해야 합니다.                                      
                                                                                                                                        
  Request                                                                                                                               
  POST /api/v1/chat/make_room/                                                                                                          
  Authorization: Bearer <access_token>                                                                                                  
  Body: 없음                                                                                                                            
                                                                                                                                        
  Response (201)                                                                                                                        
  {                                                                                                                                     
    "type": "CONNECTION_ESTABLISHED",                                                                                                   
    "session_id": "sess-1",                                                                                                             
    "message": "챗봇과의 연결이 성공했습니다.",                                                                                         
    "user_id": 1,                                                                                                                       
    "timestamp": "2026-01-28T12:00:00.000000"                                                                                           
  }                                                                                                                                     
                                                                                                                                        
  핵심: 응답의 session_id를 저장해두고, send_message 호출 시 전달해야 합니다.                                                           
                                                                                                                                        
  ---                                                                                                                                   
  2. POST /api/v1/chat/send_message/ — 채팅방 메시지 전송                                                                               
                                                                                                                                        
  생성된 채팅방에 질문을 보내면 카드 추천 정보를 응답받습니다.                                                                          
                                                                                                                                        
  Request                                                                                                                               
  POST /api/v1/chat/send_message/                                                                                                       
  Authorization: Bearer <access_token>                                                                                                  
  Content-Type: application/json                                                                                                        
  {                                                                                                                                     
    "question": "교통비 할인되는 카드 추천해줘",                                                                                        
    "session_id": "sess-1"                                                                                                              
  }                                                                                                                                     
  ┌────────────┬────────┬──────┬────────────────────────────────┐                                                                       
  │    필드    │  타입  │ 필수 │              설명              │                                                                       
  ├────────────┼────────┼──────┼────────────────────────────────┤                                                                       
  │ question   │ string │ O    │ 사용자 질문                    │                                                                       
  ├────────────┼────────┼──────┼────────────────────────────────┤                                                                       
  │ session_id │ string │ O    │ make_room에서 발급받은 세션 ID │                                                                       
  └────────────┴────────┴──────┴────────────────────────────────┘                                                                       
  Response (200)                                                                                                                        
  {                                                                                                                                     
    "type": "CARD_INFO",                                                                                                                
    "message_id": "msg-a1b2c3d4e5f6",                                                                                                   
    "session_id": "sess-1",                                                                                                             
    "user_id": 1,                                                                                                                       
    "timestamp": "2026-01-28T12:00:01.000000",                                                                                          
    "data": {                                                                                                                           
      "cards": [                                                                                                                        
        {                                                                                                                               
          "card_id": 1,                                                                                                                 
          "card_name": "신한카드 Deep On",                                                                                              
          "company": "신한카드",                                                                                                        
          "card_image_url": "https://...",                                                                                              
          "annual_fee_domestic": 15000,                                                                                                 
          "annual_fee_overseas": 15000,                                                                                                 
          "fee_waiver_rule": "전월실적 30만원 이상",                                                                                    
          "benefits": [                                                                                                                 
            {                                                                                                                           
              "benefit_id": 1,                                                                                                          
              "category_name": "교통",                                                                                                  
              "benefit_rate": "10%",                                                                                                    
              "benefit_limit": 10000                                                                                                    
            }                                                                                                                           
          ]                                                                                                                             
        }                                                                                                                               
      ]                                                                                                                                 
    }                                                                                                                                   
  }                                                                                                                                     
                                                                                                                                        
  에러 응답                                                                                                                             
  ┌──────────────┬──────┬─────────────────────┐                                                                                         
  │     상황     │ 코드 │     error_code      │                                                                                         
  ├──────────────┼──────┼─────────────────────┤                                                                                         
  │ 질문 누락    │ 400  │ EMPTY_QUESTION      │                                                                                         
  ├──────────────┼──────┼─────────────────────┤                                                                                         
  │ 채팅방 없음  │ 404  │ ROOM_NOT_FOUND      │                                                                                         
  ├──────────────┼──────┼─────────────────────┤                                                                                         
  │ AI 응답 지연 │ 504  │ AI_RESPONSE_TIMEOUT │                                                                                         
  └──────────────┴──────┴─────────────────────┘                                                                                         
  ---                                                                                                                                   
  3. GET /api/v1/chat/ — AI 채팅 기록 조회                                                                                              
                                                                                                                                        
  로그인한 사용자의 전체 AI 채팅 기록을 시간순으로 조회합니다.                                                                          
                                                                                                                                        
  Request                                                                                                                               
  GET /api/v1/chat/                                                                                                                     
  Authorization: Bearer <access_token>                                                                                                  
                                                                                                                                        
  Response (200)                                                                                                                        
  [                                                                                                                                     
    {                                                                                                                                   
      "user": 1,                                                                                                                        
      "message": "이번 달 얼마 썼어?",                                                                                                  
      "is_user": true,                                                                                                                  
      "created_at": "2026-01-28T12:00:00Z"                                                                                              
    },                                                                                                                                  
    {                                                                                                                                   
      "user": 1,                                                                                                                        
      "message": "이번 달 총 지출은 523,000원입니다. 지난달 대비...",                                                                   
      "is_user": false,                                                                                                                 
      "created_at": "2026-01-28T12:00:01Z"                                                                                              
    }                                                                                                                                   
  ]                                                                                                                                     
  ┌────────────────┬──────────────────────┐                                                                                             
  │      필드      │         설명         │                                                                                             
  ├────────────────┼──────────────────────┤                                                                                             
  │ is_user: true  │ 사용자가 보낸 메시지 │                                                                                             
  ├────────────────┼──────────────────────┤                                                                                             
  │ is_user: false │ AI가 응답한 메시지   │                                                                                             
  └────────────────┴──────────────────────┘                                                                                             
  ---                                                                                                                                   
  4. POST /api/v1/chat/ — AI 채팅 메시지 전송                                                                                           
                                                                                                                                        
  Gemini AI에게 금융 관련 질문을 보내고 응답을 받습니다. 채팅방 생성 없이 바로 사용 가능합니다.                                         
                                                                                                                                        
  Request                                                                                                                               
  POST /api/v1/chat/                                                                                                                    
  Authorization: Bearer <access_token>                                                                                                  
  Content-Type: application/json                                                                                                        
  {                                                                                                                                     
    "message": "이번 달 소비 패턴 분석해줘"                                                                                             
  }                                                                                                                                     
  ┌─────────┬────────┬──────┬──────────────────┐                                                                                        
  │  필드   │  타입  │ 필수 │       설명       │                                                                                        
  ├─────────┼────────┼──────┼──────────────────┤                                                                                        
  │ message │ string │ O    │ AI에게 보낼 질문 │                                                                                        
  └─────────┴────────┴──────┴──────────────────┘                                                                                        
  Response (200)                                                                                                                        
  {                                                                                                                                     
    "user_message": {                                                                                                                   
      "user": 1,                                                                                                                        
      "message": "이번 달 소비 패턴 분석해줘",                                                                                          
      "is_user": true,                                                                                                                  
      "created_at": "2026-01-28T12:00:00Z"                                                                                              
    },                                                                                                                                  
    "ai_message": {                                                                                                                     
      "user": 1,                                                                                                                        
      "message": "이번 달 총 지출은 523,000원입니다. 식비가 가장 큰 비중을 차지하고 있으며...",                                         
      "is_user": false,                                                                                                                 
      "created_at": "2026-01-28T12:00:01Z"                                                                                              
    }                                                                                                                                   
  }                                                                                                                                     
                                                                                                                                        
  동작 흐름:                                                                                                                            
  1. 사용자 메시지를 ChatMessage 테이블에 저장 (is_user=true)                                                                           
  2. 사용자의 이번 달 총 지출 데이터를 조회                                                                                             
  3. Gemini AI (gemini-2.0-flash)에 지출 컨텍스트 + 질문을 전달                                                                         
  4. AI 응답을 ChatMessage 테이블에 저장 (is_user=false)                                                                                
  5. 사용자 메시지와 AI 응답을 함께 반환                                                                                                
                                                                                                                                        
  ---                                                                                                                                   
  프론트엔드 연동 플로우                                                                                                                
                                                                                                                                        
  방법 A: 채팅방 기반 (카드 추천)                                                                                                       
  [로그인] → [make_room] → session_id 저장                                                                                              
                  ↓                                                                                                                     
           [send_message + session_id] → 카드 추천 응답                                                                                 
           [send_message + session_id] → 카드 추천 응답                                                                                 
           ...반복                                                                                                                      
                                                                                                                                        
  방법 B: AI 직접 대화 (금융 상담)                                                                                                      
  [로그인] → [POST /chat/] → AI 응답 (세션 불필요)                                                                                      
           [POST /chat/] → AI 응답                                                                                                      
           ...반복                                                                                                                      
           [GET /chat/] → 전체 대화 기록 조회                                                                                           
                                                                                                                                        
  두 시스템은 별도의 테이블에 저장되므로 데이터가 섞이지 않습니다. 프론트에서 용도에 맞게 선택하면 됩니다.         
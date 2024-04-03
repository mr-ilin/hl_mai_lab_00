workspace {
    name "Мессенджер"
    description "Система мессенджера"

    # включаем режим с иерархической системой идентификаторов
    !identifiers hierarchical

    # Модель архитектуры
    model {

        # Настраиваем возможность создания вложенных груп
        properties { 
            structurizr.groupSeparator "/"
        }
        

        # Описание компонент модели
        user = person "Пользователь мессенджера"

        messenger = softwareSystem "Мессенджер" {
            description "Сервер мессенджера"

            messenger_service = container "Messenger service" {
                description "Сервис мессенджера"
            }

            group "Слой данных" {
                messenger_database = container "Database" {
                    description "База данных"
                    technology "PostgreSQL 15"
                    tags "database"
                }

                messenger_cache = container "Cache" {
                    description "Кеш"
                    technology "Redis"
                    tags "database"
                }
            }

            messenger_service -> messenger_cache "Получение/обновление данных"
            messenger_service -> messenger_database "Получение/обновление данных"

            user -> messenger_service "Регистрация нового пользователя"
        }

        user -> messenger "Получение/обновление данных о сообщениях"

        deploymentEnvironment "Production" {
            deploymentNode "User Server" {
                containerInstance messenger.messenger_service
            }

            deploymentNode "databases" {
     
                deploymentNode "Database Server" {
                    containerInstance messenger.messenger_database
                }

                deploymentNode "Cache Server" {
                    containerInstance messenger.messenger_cache
                }
            }
            
        }
    }

    views {
        themes default

        properties { 
            structurizr.tooltips true
        }


        !script groovy {
            workspace.views.createDefaultViews()
            workspace.views.views.findAll { it instanceof com.structurizr.view.ModelView }.each { it.enableAutomaticLayout() }
        }

        # Пользователи

        dynamic messenger "UC01" "Добавление нового пользователя" {
            autoLayout
            user -> messenger.messenger_service "Создать нового пользователя (POST /user)"
            messenger.messenger_service -> messenger.messenger_database "Сохранить данные о пользователе" 
        }

        dynamic messenger "UC02" "Удаление пользователя" {
            autoLayout
            user -> messenger.messenger_service "Удалить нового пользователя (DELETE /user)"
            messenger.messenger_service -> messenger.messenger_database "Удалить данные о пользователе" 
        }

        dynamic messenger "UC03" "Поиск пользователя" {
            autoLayout
            user -> messenger.messenger_service "Поиск пользователя (GET /user)"
            messenger.messenger_service -> messenger.messenger_database "Поиск пользователя в БД" 
        }

        # Чаты

        dynamic messenger "UC04" "Получение чатов пользователя" {
            autoLayout
            user -> messenger.messenger_service "Получение списка чатов (GET /chats)"
            messenger.messenger_service -> messenger.messenger_database "Получение пагинированных данных о чатах" 
        }

         dynamic messenger "UC05" "Создание чата" {
            autoLayout
            user -> messenger.messenger_service "Создать новый чат(POST /chat)"
            messenger.messenger_service -> messenger.messenger_database "Сохранить данные о чате" 
        }

        # Сообщения

        dynamic messenger "UC06" "Получение сообщений чата" {
            autoLayout
            user -> messenger.messenger_service "Получение сообщений (GET /messages)"
            messenger.messenger_service -> messenger.messenger_database "Получение пагинированных данных о сообщениях" 
        }
        dynamic messenger "UC07" "Отправка сообщения в чат" {
            autoLayout
            user -> messenger.messenger_service "Отправка сообщения в чат (POST /message)"
            messenger.messenger_service -> messenger.messenger_database "Сохранить данные о сообщении" 
        }

        styles {
            element "database" {
                shape cylinder
            }
        }
    }
}
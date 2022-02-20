---
title: spring注解原理-IOC1 组件注册
date: 2022-01-25 19:36:57
tags: IOC
categories: Spring原理
---

快过年了感觉还是挺忙的，这两天把毕设论文写了写，然后想着学点别的，看了看尚硅谷的学习路线发现我有些学过去现在已经记不清了...本来想着看看哪些消息中间件之类的，发现基础有些还是没有掌握好，还是先补补基础吧......

开始看雷神的spring注解驱动，这里就整理以下讲到的注解之类的内容吧!

<!--more-->

[TOC]

------

# @ComponentScan 

作用是自动扫描组件并可以指定扫描规则

点开ComponentScan 注解类查看源码：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/25/1643111698.png)



![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/25/1643111945.png)

1. 如果需要在扫描时排除标注的类：

   ```java
   @ComponentScan(value = "com.zsxfa", excludeFilters={
   		/*
   		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
   		 * classes：除了@Controller和@Service标注的组件之外，IOC容器中剩下的组件都会扫描到。
   		 */
   		@ComponentScan.Filter(type=FilterType.ANNOTATION, classes={Controller.class, Service.class})
   }) // value指定要扫描的包
   ```

2. 如果需要在扫描时只包含标注的类：

   ```java
   @ComponentScan(value = "com.zsxfa", includeFilters = {
       	/*
   		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
   		 * classes：我们需要Spring在扫描时，只包含@Controller注解标注的类
   		 */
           @ComponentScan.Filter(type = FilterType.ANNOTATION, classes = {Controller.class, Service.class})
   }, useDefaultFilters=false)// value指定要扫描的包
   ```

## 重复注解

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/25/1643113696.png)

先来看看@ComponentScans注解，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/25/1643113932.png)

在ComponentScans注解类的内部声明了一个返回ComponentScan[]数组的value()方法，所以我们可以在@ComponentScan注解中重复使用：

```java
@ComponentScan(value="com.zsxfa", includeFilters={
		/*
		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
		 * classes：我们需要Spring在扫描时，只包含@Controller注解标注的类
		 */
		@Filter(type=FilterType.ANNOTATION, classes={Controller.class})
}, useDefaultFilters=false) // value指定要扫描的包
@ComponentScan(value="com.zsxfa", includeFilters={
		/*
		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
		 * classes：我们需要Spring在扫描时，只包含@Service注解标注的类
		 */
		@Filter(type=FilterType.ANNOTATION, classes={Service.class})
}, useDefaultFilters=false) // value指定要扫描的包
```

------

# @Filter

使用@ComponentScan注解实现包扫描时，我们可以使用@Filter指定过滤规则

@Filter注解中的type属性是一个FilterType枚举，源码如下：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643160268.png)

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643160412.png)

## FilterType.ANNOTATION：按照注解进行包含或者排除

扫描只包含标注了@Controller注解的组件

```java
@ComponentScan(value="com.zsxfa", includeFilters={
		/*
		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
		 * classes：我们需要Spring在扫描时，只包含@Controller注解标注的类
		 */
		@Filter(type=FilterType.ANNOTATION, classes={Controller.class})
}, useDefaultFilters=false) // value指定要扫描的包
```

## FilterType.ASSIGNABLE_TYPE：按照给定的类型进行包含或者排除

扫描BookService这种类型的组件，如果是Java类，就包括子类 如果是接口，就包括实现类。

```java
@ComponentScan(value="com.zsxfa", includeFilters={
		/*
		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
		 */
		// 只要是BookService这种类型的组件都会被加载到容器中，不管是它的子类还是什么它的实现类。记住，只要是BookService这种类型的
		@Filter(type=FilterType.ASSIGNABLE_TYPE, classes={BookService.class})
}, useDefaultFilters=false) // value指定要扫描的包
```

## FilterType.ASPECTJ：按照ASPECTJ表达式进行包含或者排除

按照ASPECTJ表达式进行过滤（不常用）

```java
@ComponentScan(value="com.zsxfa", includeFilters={
		/*
		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
		 */
		@Filter(type=FilterType.ASPECTJ, classes={AspectJTypeFilter.class})
}, useDefaultFilters=false) // value指定要扫描的包
```

## FilterType.REGEX：按照正则表达式进行包含或者排除

按照正则表达式进行过滤（不常用）

```java
@ComponentScan(value="com.zsxfa", includeFilters={
		/*
		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
		 */
		@Filter(type=FilterType.REGEX, classes={RegexPatternTypeFilter.class})
}, useDefaultFilters=false) // value指定要扫描的包
```

## FilterType.CUSTOM：按照自定义规则进行包含或者排除

如果实现自定义规则进行过滤时，自定义规则的类必须是**org.springframework.core.type.filter.TypeFilter**接口的**实现类**。

1. 创建TypeFilter接口的实现类MyTypeFilter：

   ```java
   public class MyTypeFilter implements TypeFilter {
   	/**
   	 * 参数：
   	 * metadataReader：读取到的当前正在扫描的类的信息
   	 * metadataReaderFactory：可以获取到其他任何类的信息的（工厂）
   	 */
   	@Override
   	public boolean match(MetadataReader metadataReader, MetadataReaderFactory metadataReaderFactory) throws IOException {
   	
   		return false; // 这儿我们先让其返回false
   	}
   }
   ```

   当我们实现TypeFilter接口时，需要实现该接口中的match()方法，match()方法的返回值为boolean类型。

   - 当返回true时，表示符合规则，会包含在Spring容器中；
   - 当返回false时，表示不符合规则，不会被包含在Spring容器中。

2. 使用@ComponentScan注解进行如下配置。

   ```java
   @ComponentScan(value="com.zsxfa", includeFilters={
   		/*
   		 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
   		 */
   		// 指定新的过滤规则，这个过滤规则是我们自个自定义的，过滤规则就是由我们这个自定义的MyTypeFilter类返回true或者false来代表匹配还是没匹配
   		@Filter(type=FilterType.CUSTOM, classes={MyTypeFilter.class})
   }, useDefaultFilters=false) // value指定要扫描的包
   ```

## 实现自定义过滤规则

1. 在MyTypeFilter类中打印出当前正在扫描的类名

   ```java
   public class MyTypeFilter implements TypeFilter {
   	/**
   	 * 参数：
   	 * metadataReader：读取到的当前正在扫描的类的信息
   	 * metadataReaderFactory：可以获取到其他任何类的信息的（工厂）
   	 */
   	@Override
   	public boolean match(MetadataReader metadataReader, MetadataReaderFactory metadataReaderFactory) throws IOException {
   		// 获取当前类注解的信息
   		AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
   		// 获取当前正在扫描的类的类信息，比如说它的类型是什么，它实现了什么接口之类的
   		ClassMetadata classMetadata = metadataReader.getClassMetadata();
   		// 获取当前类的资源信息，比如说类的路径等信息
   		Resource resource = metadataReader.getResource();
   		// 获取当前正在扫描的类的类名
   		String className = classMetadata.getClassName();
   		System.out.println("->" + className);
   		
   		return false;
   	}
   }
   ```

2. 在MainConfig类中配置自定义过滤规则:

   ```java
   //以前配置文件的方式被替换成了配置类，即配置类==配置文件
   // 这个配置类也是一个组件
   @ComponentScans(value={
   		@ComponentScan(value="com.zsxfa", includeFilters={
   				/*
   				 * type：指定你要排除的规则，是按照注解进行排除，还是按照给定的类型进行排除，还是按照正则表达式进行排除，等等
   				 */
   				// 指定新的过滤规则，这个过滤规则是我们自个自定义的，过滤规则就是由我们这个自定义的MyTypeFilter类返回true或者false来代表匹配还是没匹配
   				@Filter(type=FilterType.CUSTOM, classes={MyTypeFilter.class})
   		}, useDefaultFilters=false) // value指定要扫描的包
   })
   @Configuration // 告诉Spring这是一个配置类
   public class MainConfig {
   
   	// @Bean注解是给IOC容器中注册一个bean，类型自然就是返回值的类型，id默认是用方法名作为id
   	@Bean("person")
   	public Person person01() {
   		return new Person("lisi", 20);
   	}
   	
   }
   ```

3. 接着，运行IOCTest类中的test01()方法进行测试

   ```java
   @Test
   public void test01() {
       AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
       // 我们现在就来看一下IOC容器中有哪些bean，即容器中所有bean定义的名字
       String[] definitionNames = applicationContext.getBeanDefinitionNames();
       for (String name : definitionNames) {
           System.out.println(name);
       }
   }
   ```

4. 输出结果如下：

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643162142.png)

   - 可以看到，已经输出了当前正在扫描的类的名称，同时，除了Spring内置的bean的名称之外，只输出了**mainConfig**和**person**，而没有输出使用@Repository、@Service、@Controller这些注解标注的组件的名称。
   - 这是因为当前MainConfig类上标注的@ComponentScan注解是使用的自定义规则，而在自定义规则的实现类（即MyTypeFilter类）中，直接返回了false，那么就是一个都不匹配，所有的bean都没被包含进容器中。

5. 我们可以在MyTypeFilter类中简单的实现一个规则，例如，当前扫描的类名称中包**含有"er"字符串的**，就返回true，否则就返回false。

   ```java
   public class MyTypeFilter implements TypeFilter {
   	/**
   	 * 参数：
   	 * metadataReader：读取到的当前正在扫描的类的信息
   	 * metadataReaderFactory：可以获取到其他任何类的信息的（工厂）
   	 */
   	@Override
   	public boolean match(MetadataReader metadataReader, MetadataReaderFactory metadataReaderFactory) throws IOException {
   		// 获取当前类注解的信息
   		AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
   		// 获取当前正在扫描的类的类信息，比如说它的类型是什么啊，它实现了什么接口啊之类的
   		ClassMetadata classMetadata = metadataReader.getClassMetadata();
   		// 获取当前类的资源信息，比如说类的路径等信息
   		Resource resource = metadataReader.getResource();
   		// 获取当前正在扫描的类的类名
   		String className = classMetadata.getClassName();
   		System.out.println("--->" + className);
   		// 现在来指定一个规则
   		if (className.contains("er")) {
   			return true; // 匹配成功，就会被包含在容器中
   		}	
   		return false; // 匹配不成功，所有的bean都会被排除
   	}
   }
   ```

6. 输出结果如下：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643162630.png)

​	包括MyTypeFilter的原因是因为扫描的是com.zsxfa包，这个包下的每个类都会进入到这个自定义规则里面进行匹配，若匹配成功，则就会被包含在容器中。

# @Scope

Spring容器中的组件默认是单例的，在Spring启动时就会实例化并初始化这些对象，并将其放到Spring容器中，之后，每次获取对象时，直接从Spring容器中获取，而不再创建对象。如果每次从Spring容器中获取对象时，都要创建一个新的实例对象，那么该如何处理呢？此时就需要使用@Scope注解来设置组件的作用域了。

## @Scope注解原理

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643163613.png)

可以看到ConfigurableBeanFactory，点开ConfigurableBeanFactory的源码：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643163701.png)

singleton代表单实例，prototype代表多实例

## 单实例Bean创建对象的时机

Spring容器在启动时，将单实例组件实例化之后，会即刻加载到Spring容器中，以后每次从容器中获取组件实例对象时，都是直接返回相应的对象，而不必再创建新的对象了。

## 多实例Bean创建对象的时机

当向Spring容器中获取Bean实例对象时，Spring容器才会实例化Bean对象，再将其加载到Spring容器中去。

每次向Spring容器获取对象时，它都会创建一个新的对象并返回。

## 单实例bean注意的事项

单实例bean是整个应用所共享的，所以需要考虑到线程安全问题，，SpringMVC中的Controller默认是单例的，有些开发者在Controller中创建了一些变量，那么这些变量实际上就变成共享的了，Controller又可能会被很多线程同时访问，这些线程并发去修改Controller中的共享变量，此时很有可能会出现数据错乱的问题

## 多实例bean注意的事项

多实例bean每次获取的时候都会重新创建，如果这个bean比较复杂，创建时间比较长，那么就会影响系统的性能

# @Lazy-bean懒加载

Spring在启动时，默认会将单实例bean进行实例化，并加载到Spring容器中去。也就是说，单实例bean默认是在Spring容器启动的时候创建对象，并且还会将对象加载到Spring容器中。如果我们需要对某个bean进行延迟加载，那么该如何处理呢？此时，就需要使用到@Lazy注解了。

## 懒加载：

- 懒加载就是Spring容器启动的时候，先不创建对象，在第一次使用（获取）bean的时候再来创建对象，并进行一些初始化。

## 懒加载实现：

1. 首先，我们在MainConfig2配置类中的person()方法上加上一个@Lazy注解，以此将Person对象设置为懒加载

   ```java
   @Configuration
   public class MainConfig2 {
       @Lazy
       @Bean("person")
       public Person person() {
           System.out.println("给容器中添加这个Person对象...");
           return new Person("marx", 25);
       }
   }
   ```

2. 运行IOCTest类中的test05()方法

   发现没有输出注入bean时的语句

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643164548.png)

3. 在IOCTest类中的test05()方法中获取一下Person对象

   ```java
   @Test
   public void test05() {
       AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig2.class);
       System.out.println("IOC容器创建完成");
       Person person = (Person) applicationContext.getBean("person");
   }
   ```

   再次运行：

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643164750.png)

4. 验证是否创建了多个bean

   ```java
   @Test
   public void test05() {
       AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig2.class);
       System.out.println("IOC容器创建完成");
       Person person = (Person) applicationContext.getBean("person");
       Person person2 = (Person) applicationContext.getBean("person");
       System.out.println(person == person2);
   }
   ```

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643164930.png)

   **说明没有多创建bean，实现了懒加载。**

# @Conditional

@Conditional注解可以按照一定的条件进行判断，满足条件向容器中注册bean，不满足条件就不向容器中注册bean。

@Conditional注解是由Spring Framework提供的一个注解，它位于 org.springframework.context.annotation包内，定义如下。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643165502.png)

从@Conditional注解的源码来看，@Conditional注解不仅可以添加到类上，也可以添加到方法上。在@Conditional注解中，还存在着一个Condition类型或者其子类型的Class对象数组，我们点进去看一下。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643165599.png)

可以看到，它是一个接口。所以，我们使用@Conditional注解时，需要写一个类来实现Spring提供的Condition接口，它会匹配@Conditional所符合的方法，然后我们就可以使用我们在@Conditional注解中定义的类来检查了。

## 向Spring容器注册bean

在MainConfig2配置类中新增person01()方法和person02()方法，并为这两个方法添加@Bean注解

```java
@Configuration
public class MainConfig2 {

    @Lazy
    @Bean("person")
    public Person person() {
        System.out.println("给容器中添加这个Person对象...");
        return new Person("marx", 25);
    }

    @Bean("bill")
    public Person person01() {
        return new Person("Bill Gates", 62);
    }

    @Bean("linus")
    public Person person02() {
        return new Person("linus", 48);
    }
}
```

### 带条件注册bean

如果当前操作系统是Windows操作系统，那么就向Spring容器中注册名称为bill的Person对象；如果当前操作系统是Linux操作系统，那么就向Spring容器中注册名称为linus的Person对象。要想实现这个需求，我们就得要使用@Conditional注解了。

**使用Spring中的AnnotationConfigApplicationContext类就能够获取到当前操作系统的类型**

```java
@Test
public void test06() {
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig2.class);
    // 我们现在就来看一下IOC容器中Person这种类型的bean都有哪些
    String[] namesForType = applicationContext.getBeanNamesForType(Person.class);
    ConfigurableEnvironment environment = applicationContext.getEnvironment(); // 拿到IOC运行环境
    // 动态获取坏境变量的值，例如操作系统的名字
    String property = environment.getProperty("os.name"); // 获取操作系统的名字，例如Windows 10
    System.out.println(property);
    
    for (String name : namesForType) {
        System.out.println(name);
    }
    
    Map<String, Person> persons = applicationContext.getBeansOfType(Person.class); // 找到这个Person类型的所有bean
    System.out.println(persons);
}
```

要想使用@Conditional注解，我们需要实现Condition接口来为@Conditional注解设置条件，所以，这里我们创建了两个实现Condition接口的类，它们分别是LinuxCondition和WindowsCondition，如下所示。

1. LinuxCondition

   ```java
   public class LinuxCondition implements Condition {
   
       /**
        * ConditionContext：判断条件能使用的上下文（环境）
        * AnnotatedTypeMetadata：当前标注了@Conditional注解的注释信息
        */
       @Override
       public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
           // 判断操作系统是否是Linux系统
           // 1. 获取到bean的创建工厂（能获取到IOC容器使用到的BeanFactory，它就是创建对象以及进行装配的工厂）
           ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();
           // 2. 获取到类加载器
           ClassLoader classLoader = context.getClassLoader();
           // 3. 获取当前环境信息，它里面就封装了我们这个当前运行时的一些信息，包括环境变量，以及包括虚拟机的一些变量
           Environment environment = context.getEnvironment();
           // 4. 获取到bean定义的注册类
           BeanDefinitionRegistry registry = context.getRegistry();
           String property = environment.getProperty("os.name");
           if (property.contains("linux")) {
               return true;
           }
           return false;
       }
   }
   ```

   #### 	BeanDefinitionRegistry对象的源码：

   ​	![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643166521.png)

   Spring容器中所有的bean都可以通过BeanDefinitionRegistry对象来进行注册，因此我们可以通过它来查看Spring容器中到底注册了哪些bean。

   因此，我们可以在这儿做更多的判断，比如说我可以判断一下Spring容器中是不是包含有某一个bean，就像下面这样，如果Spring容器中果真包含有名称为person的bean，那么就做些什么事情，如果没包含，那么我们还可以利用BeanDefinitionRegistry对象向Spring容器中注册一个bean。

2. WindowsCondition

   ```java
   public class WindowsCondition implements Condition {
       @Override
       public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
           Environment environment = context.getEnvironment();
           String property = environment.getProperty("os.name");
           if (property.contains("Windows")) {
               return true;
           }
           return false;
       }
   }
   ```

3. 在MainConfig2配置类中使用@Conditional注解添加条件：

   ```java
   @Configuration
   public class MainConfig2 {
   
       @Lazy
       @Bean("person")
       public Person person() {
           System.out.println("给容器中添加这个Person对象...");
           return new Person("marx", 25);
       }
   
       @Conditional({WindowsCondition.class})
       @Bean("bill")
       public Person person01() {
           return new Person("Bill Gates", 62);
       }
   
       @Conditional({LinuxCondition.class})
       @Bean("linus")
       public Person person02() {
           return new Person("linus", 48);
       }
   }
   ```

   运行结果如下：没有名称为linus的bean了

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643166774.png)

4. @Conditional注解也可以标注在类上，标注在类上的含义是：只有满足了当前条件，这个配置类中配置的所有bean注册才能生效，也就是对配置类中的组件进行统一设置。

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643166866.png)

5. 此时，我们在运行IOCTest类中的test06()方法时，设置一个`-Dos.name=linux`参数，就像下图所示的那样，这是我们将操作系统模拟为了linux系统。

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643166991.png)

   运行结果如下：可以看到，没有任何bean的定义信息输出，这是因为程序检测到了当前操作系统为linux，没有向Spring容器中注册任何bean的缘故导致的。

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643167025.png)

# @Import

在项目中会经常引入一些第三方的类库，我们需要将这些第三方类库中的类注册到Spring容器中，此时，我们就可以使用@Bean和@Import注解将这些类快速的导入Spring容器中。

## 注册bean的方式

1. 包扫描+给组件标注注解（@Controller、@Servcie、@Repository、@Component），但这种方式比较有局限性，局限于我们自己写的类
2. @Bean注解，通常用于导入第三方包中的组件
3. @Import注解，快速向Spring容器中导入一个组件

## @Import注解源码

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643167579.png)

从源码里面可以看出@Import可以配合`Configuration`、`ImportSelector`以及`ImportBeanDefinitionRegistrar`来使用，下面的or表示也可以把Import当成普通的bean来使用。

**注意：@Import注解只允许放到类上面，不允许放到方法上。**

## @Import注解的使用方式

@Import注解的三种用法主要包括：

1. 直接填写class数组的方式
2. **ImportSelector接口的方式，即批量导入，重点**
3. ImportBeanDefinitionRegistrar接口方式，即手工注册bean到容器中

### 1. @Import导入组件的示例

我们创建一个Color类，这个类是一个空类，没有成员变量和方法，如下所示。

```java
public class Color {
}
```

在MainConfig2配置类上添加一个@Import注解，并将Color类填写到该注解中，如下所示。

```java
@Conditional({WindowsCondition.class}) // 满足当前条件，这个类中配置的所有bean注册才能生效
@Configuration
@Import(Color.class) // @Import快速地导入组件，id默认是组件的全类名
public class MainConfig2 {

    @Lazy
    @Bean("person")
    public Person person() {
        System.out.println("给容器中添加这个Person对象...");
        return new Person("marx", 25);
    }

    @Conditional({WindowsCondition.class})
    @Bean("bill")
    public Person person01() {
        return new Person("Bill Gates", 62);
    }

    @Conditional({LinuxCondition.class})
    @Bean("linus")
    public Person person02() {
        return new Person("linus", 48);
    }
}
```

运行IOCTest类中的testImport()方法，会发现输出的结果信息如下所示

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643168096.png)

可以看到，输出结果中打印了com.meimeixia.bean.Color，说明使用@Import注解快速地导入组件时，容器中就会自动注册这个组件，并且id默认是组件的全类名。

**@Import注解还支持同时导入多个类**

```java
@Import({Color.class, Red.class})
```

### 2. 使用ImportSelector

- ImportSelector源码：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643168574.png)

该接口文档上说的明明白白，其主要作用是收集需要导入的配置类，selectImports()方法的返回值就是我们向Spring容器中导入的类的全类名。如果该接口的实现类同时实现EnvironmentAware，BeanFactoryAware，BeanClassLoaderAware或者ResourceLoaderAware，那么在调用其selectImports()方法之前先调用上述接口中对应的方法，如果需要在所有的@Configuration处理完再导入时，那么可以实现DeferredImportSelector接口。

在ImportSelector接口的selectImports()方法中，存在一个AnnotationMetadata类型的参数，这个参数能够获取到当前标注@Import注解的类的所有注解信息，也就是说不仅能获取到@Import注解里面的信息，还能获取到其他注解的信息。

- **ImportSelector实例**

创建一个MyImportSelector类实现ImportSelector接口，如下所示，先在selectImports()方法中返回null

```java
public class MyImportSelector implements ImportSelector {
    // 返回值：就是要导入到容器中的组件的全类名
    // AnnotationMetadata：当前标注@Import注解的类的所有注解信息，也就是说不仅能获取到@Import注解里面的信息，还能获取到其他注解的信息
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) { // 在这一行打个断点，debug调试一下
        return null;
    }
}
```

在MainConfig2配置类的@Import注解中，导入MyImportSelector类，如下。

```java
@Import({Color.class, Red.class, MyImportSelector.class})
```

至于使用MyImportSelector类要导入哪些bean，就需要你在MyImportSelector类的selectImports()方法中进行设置了，只须在MyImportSelector类的selectImports()方法中返回要导入的类的全类名（包名+类名）即可。

接着，我们就要运行IOCTest类中的testImport()方法了，在运行该方法之前，咱们先在MyImportSelector类的selectImports()方法处打一个断点，debug调试一下，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643168898.png)

打好断点之后，我们再以debug的方式来运行IOCTest类中的testImport()方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643169052.png)

点击下一步，发现importClassName为null了，最后报错空指针异常。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643169162.png)

因此要想不报这样一个空指针异常，咱们MyImportSelector类的selectImports()方法里面就不能返回一个null值了，不妨先返回一个空数组试试，就像下面这样。

```java
public class MyImportSelector implements ImportSelector {
    // 返回值：就是要导入到容器中的组件的全类名
    // AnnotationMetadata：当前标注@Import注解的类的所有注解信息，也就是说不仅能获取到@Import注解里面的信息，还能获取到其他注解的信息
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) { // 在这一行打个断点，debug调试一下
        // 方法不要返回null值，否则会报空指针异常
        return new String[]{}; // 可以返回一个空数组
    }
}
```

再次运行就不会报错了，正常输出结果。

创建两个Java类Bule类和Yellow类如下

```
public class Bule {
}
```

```
public class Yellow {
}
```

将以上两个类的全类名返回到MyImportSelector类的selectImports()方法中，此时，MyImportSelector类的selectImports()方法如下所示。

```java
public class MyImportSelector implements ImportSelector {
    // 返回值：就是要导入到容器中的组件的全类名
    // AnnotationMetadata：当前标注@Import注解的类的所有注解信息，也就是说不仅能获取到@Import注解里面的信息，还能获取到其他注解的信息
    @Override
    public String[] selectImports(AnnotationMetadata importingClassMetadata) { // 在这一行打个断点，debug调试一下
        // 方法不要返回null值，否则会报空指针异常
//        return new String[]{}; // 可以返回一个空数组
        return new String[]{"com.zsxfa.bean.Bule", "com.zsxfa.bean.Yellow"};
    }
}
```

输出结果如下：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643169427.png)

### 3.ImportBeanDefinitionRegistrar

- ImportBeanDefinitionRegistrar的源码：

  - 

  ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643169606.png)

  由源码可以看出，ImportBeanDefinitionRegistrar本质上是一个接口。在ImportBeanDefinitionRegistrar接口中，有一个registerBeanDefinitions()方法，通过该方法，我们可以向Spring容器中注册bean实例。

  Spring官方在动态注册bean时，大部分套路其实是使用ImportBeanDefinitionRegistrar接口。

  所有实现了该接口的类都会被ConfigurationClassPostProcessor处理，ConfigurationClassPostProcessor实现了BeanFactoryPostProcessor接口，所以ImportBeanDefinitionRegistrar中动态注册的bean是优先于依赖其的bean初始化的，也能被aop、validator等机制处理。

- **使用方法**
  ImportBeanDefinitionRegistrar需要配合@Configuration和@Import这俩注解，其中，@Configuration注解定义Java格式的Spring配置文件，@Import注解导入实现了ImportBeanDefinitionRegistrar接口的类。

- **ImportBeanDefinitionRegistrar接口实例**

  就创建一个MyImportBeanDefinitionRegistrar类，去实现ImportBeanDefinitionRegistrar接口

  ```java
  public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
  
      /**
       * AnnotationMetadata：当前类的注解信息
       * BeanDefinitionRegistry：BeanDefinition注册类
       *
       * 我们可以通过调用BeanDefinitionRegistry接口中的registerBeanDefinition方法，手动注册所有需要添加到容器中的bean
       */
      @Override
      public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
  
      }
  }
  ```

  ​	在MainConfig2配置类上的@Import注解中，添加MyImportBeanDefinitionRegistrar类

  ```java
  @Import({Color.class, MyImportSelector.class, MyImportBeanDefinitionRegistrar.class}) // @Import快速地导入组件，id默认是组件的全类名
  ```

  接着，创建一个RainBow类，作为测试ImportBeanDefinitionRegistrar接口的bean来使用，如下所示。

  ```
  public class RainBow {
  }
  ```

  紧接着，我们就要实现MyImportBeanDefinitionRegistrar类中的registerBeanDefinitions()方法里面的逻辑了，添加逻辑后的registerBeanDefinitions()方法如下所示。

  ```java
  public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {
      /**
       * AnnotationMetadata：当前类的注解信息
       * BeanDefinitionRegistry：BeanDefinition注册类
       *
       * 我们可以通过调用BeanDefinitionRegistry接口中的registerBeanDefinition方法，手动注册所有需要添加到容器中的bean
       */
      @Override
      public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
          boolean definition = registry.containsBeanDefinition("com.zsxfa.bean.Yellow");
          boolean definition2 = registry.containsBeanDefinition("com.zsxfa.bean.Bule");
          if (definition && definition2) {
              // 指定bean的定义信息，包括bean的类型、作用域等等
              // RootBeanDefinition是BeanDefinition接口的一个实现类
              RootBeanDefinition beanDefinition = new RootBeanDefinition(RainBow.class); // bean的定义信息
              // 注册一个bean，并且指定bean的名称
              registry.registerBeanDefinition("rainBow", beanDefinition);
          }
      }
  }
  ```

  以上registerBeanDefinitions()方法的实现逻辑很简单，就是判断Spring容器中是否同时存在以`com.zsxfa.bean.Yellow`命名的bean和以`com.zsxfa.bean.Bule`命名的bean，如果真的同时存在，那么向Spring容器中注入一个以rainBow命名的bean。

  运行IOCTest类中的testImport()方法来进行测试，输出结果信息如下所示。

  ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643170058.png)

# 使用FactoryBean向Spring容器中注册bean

我们可以通过多种方式向Spring容器中注册bean。可以使用@Configuration注解结合@Bean注解向Spring容器中注册bean；可以按照条件向Spring容器中注册bean；可以使用@Import注解向容器中快速导入bean对象；可以在@Import注解中使用ImportBeanDefinitionRegistrar向容器中注册bean。

## FactoryBean概述

一般情况下，Spring是通过反射机制利用bean的class属性指定实现类来实例化bean的。在某些情况下，实例化bean过程比较复杂，如果按照传统的方式，那么则需要在标签中提供大量的配置信息，配置方式的灵活性是受限的，这时采用编码的方式可以得到一个更加简单的方案。Spring为此提供了一个org.springframework.bean.factory.FactoryBean的工厂类接口，用户可以通过实现该接口定制实例化bean的逻辑。

FactoryBean接口对于Spring框架来说占有非常重要的地位，Spring自身就提供了70多个FactoryBean接口的实现。它们隐藏了实例化一些复杂bean的细节，给上层应用带来了便利。从Spring 3.0开始，FactoryBean开始支持泛型，即接口声明改为FactoryBean<T>的形式。

在`Spring 4.3.12.RELEASE`这个版本中，FactoryBean接口的定义如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643174094.png)

这里，需要注意的是：当配置文件中标签的class属性配置的实现类是FactoryBean时，通过 getBean()方法返回的不是FactoryBean本身，而是FactoryBean#getObject()方法所返回的对象，相当于FactoryBean#getObject()代理了getBean()方法。

## FactoryBean实例

首先，创建一个ColorFactoryBean类，它得实现FactoryBean接口，如下所示。

```java
public class ColorFactoryBean implements FactoryBean<Color> {
    // 返回一个Color对象，这个对象会添加到容器中
    @Override
    public Color getObject() throws Exception {
        // TODO Auto-generated method stub
        System.out.println("ColorFactoryBean...getObject...");
        return new Color();
    }
    @Override
    public Class<?> getObjectType() {
        // TODO Auto-generated method stub
        return Color.class; // 返回这个对象的类型
    }
    // 是单例吗？
    // 如果返回true，那么代表这个bean是单实例，在容器中只会保存一份；
    // 如果返回false，那么代表这个bean是多实例，每次获取都会创建一个新的bean
    @Override
    public boolean isSingleton() {
        // TODO Auto-generated method stub
        return false;
    }
}
```

然后，我们在MainConfig2配置类中加入ColorFactoryBean的声明，如下所示。

```java
@Configuration
@Import({Color.class, MyImportSelector.class, MyImportBeanDefinitionRegistrar.class}) // @Import快速地导入组件，id默认是组件的全类名
@Conditional({WindowsCondition.class})
public class MainConfig2 {

    @Lazy
    @Bean("person")
    public Person person() {
        System.out.println("给容器中添加这个Person对象...");
        return new Person("marx", 25);
    }

    @Bean("bill")
    public Person person01() {
        return new Person("Bill Gates", 62);
    }

    @Conditional({LinuxCondition.class})
    @Bean("linus")
    public Person person02() {
        return new Person("linus", 48);
    }

    @Bean
    public ColorFactoryBean colorFactoryBean() {
        return new ColorFactoryBean();
    }
}
```

这里需要注意的是：我在这里使用@Bean注解向Spring容器中注册的是ColorFactoryBean对象。

那现在我们就来看看Spring容器中到底都有哪些bean。我们所要做的事情就是，运行IOCTest类中的testImport()方法，此时，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643174448.png)

可以看到，结果信息中输出了一个colorFactoryBean！此时，我们对IOCTest类中的testImport()方法稍加改动，添加获取colorFactoryBean的代码，并输出colorFactoryBean实例的类型，如下所示。

```java
@Test
public void testImport() {
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig2.class);
    String[] definitionNames = applicationContext.getBeanDefinitionNames();
    for (String name : definitionNames) {
        System.out.println(name);
    }

    // 工厂bean获取的是调用getObject方法创建的对象
    Object bean2 = applicationContext.getBean("colorFactoryBean");
    System.out.println("bean的类型：" + bean2.getClass());
}
```

再次运行IOCTest类中的testImport()方法，发现输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643174821.png)

可以看到，虽然我在代码中使用@Bean注解注入的是ColorFactoryBean对象，但是实际上从Spring容器中获取到的bean对象却是调用ColorFactoryBean类中的getObject()方法获取到的Color对象。

在ColorFactoryBean类中，我们将Color对象设置为单实例bean，即让isSingleton()方法返回true。接下来，我们在IOCTest类中的testImport()方法里面多次获取Color对象，并判断一下多次获取的对象是否为同一对象，如下所示。

```java
@Test
public void testImport() {
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig2.class);
    String[] definitionNames = applicationContext.getBeanDefinitionNames();
    for (String name : definitionNames) {
        System.out.println(name);
    }

    // 工厂bean获取的是调用getObject方法创建的对象
    Object bean2 = applicationContext.getBean("colorFactoryBean");
    Object bean3 = applicationContext.getBean("colorFactoryBean");
    System.out.println("bean的类型：" + bean2.getClass());
    System.out.println(bean2 == bean3);
}
```

然后，运行IOCTest类中的testImport()方法，此时输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643174981.png)

可以看到，在ColorFactoryBean类中的isSingleton()方法里面返回true时，每次获取到的Color对象都是同一个对象，说明Color对象是单实例bean。

## 如何在Spring容器中获取到FactoryBean对象本身？

**只需要在获取工厂Bean本身时，在id前面加上&符号即可，例如&colorFactoryBean。**

打开我们的IOCTest测试类，在testImport()方法中添加获取ColorFactoryBean实例的代码，如下所示。

```java
@Test
public void testImport() {
    AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig2.class);
    String[] definitionNames = applicationContext.getBeanDefinitionNames();
    for (String name : definitionNames) {
        System.out.println(name);
    }

    // 工厂bean获取的是调用getObject方法创建的对象
    Object bean2 = applicationContext.getBean("colorFactoryBean");
    Object bean3 = applicationContext.getBean("colorFactoryBean");
    System.out.println("bean的类型：" + bean2.getClass());
    System.out.println(bean2 == bean3);

    Object bean4 = applicationContext.getBean("&colorFactoryBean");
    System.out.println(bean4.getClass());
}
```

此时，运行以上testImport()方法，会发现输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643175176.png)

**为什么在id前面加上&符号就会获取到ColorFactoryBean实例对象呢？**

打开**BeanFactory**接口，查看其源码。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/26/1643175284.png)

在BeanFactory接口中定义了一个&前缀，只要我们使用bean的id来从Spring容器中获取bean时，Spring就会知道我们是在获取FactoryBean本身。




---
title: spring注解原理-AOP原理
date: 2022-02-04 21:05:38
tags: AOP
categories: Spring原理
---

# 1. 搭建一个AOP测试环境

## 什么是AOP？

AOP（Aspect Orient Programming），直译过来就是面向切面编程。AOP是一种编程思想，是面向对象编程（OOP）的一种补充。面向对象编程将程序抽象成各个层次的对象，而面向切面编程是将程序抽象成各个切面。

<!--more-->

比如，在《Spring实战（第4版）》中有如下一张图描述了AOP的大体模型。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/28/1643333428.png)

从这张图中，我们可以看出：所谓切面，其实就相当于应用对象间的横切点，我们可以将其单独抽象为单独的模块。

**AOP是指在程序的运行期间动态地将某段代码切入到指定方法、指定位置进行运行的编程方式。AOP的底层是使用动态代理实现的。**

## 实战案例

### （一）导入AOP依赖

要想搭建AOP环境，首先，我们就需要在项目的pom.xml文件中引入AOP的依赖，如下所示。

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aspects</artifactId>
    <version>4.3.12.RELEASE</version>
</dependency>
```

其实，Spring AOP对面向切面编程做了一些简化操作，我们只需要加上几个核心注解，AOP就能工作起来。

### （二）定义目标类

在com.zsxfa.aop包下创建一个业务逻辑类，例如MathCalculator，用于处理数学计算上的一些逻辑。比如，我们在MathCalculator类中定义了一个除法操作，返回两个整数类型值相除之后的结果，如下所示。

```java
public class MathCalculator {

    public int div(int i, int j) {
        System.out.println("MathCalculator...div...");
        return i / j;
    }
}
```

现在，我们希望在以上这个业务逻辑类中的除法运算之前，记录一下日志，例如记录一下哪个方法运行了，用的参数是什么，运行结束之后它的返回值又是什么，顺便可以将其打印出来，还有如果运行出异常了，那么就捕获一下异常信息。

或者，你会有这样一个需求，即希望在业务逻辑运行的时候将日志进行打印，而且是在方法运行之前、方法运行结束、方法出现异常等等位置，都希望会有日志打印出来。

### （三）定义切面类

在com.zsxfa.aop包下创建一个切面类，例如LogAspects，在该切面类中定义几个打印日志的方法，以这些方法来动态地感知MathCalculator类中的div()方法的运行情况。如果需要切面类来动态地感知目标类方法的运行情况，那么就需要使用Spring AOP中的一系列通知方法了。

AOP中的通知方法及其对应的注解与含义如下：

- 前置通知（对应的注解是@Before）：在目标方法运行之前运行
- 后置通知（对应的注解是@After）：在目标方法运行结束之后运行，**无论目标方法是正常结束还是异常结束都会执行**
- 返回通知（对应的注解是@AfterReturning）：在目标方法正常返回之后运行
- 异常通知（对应的注解是@AfterThrowing）：在目标方法运行出现异常之后运行
- 环绕通知（对应的注解是@Around）：动态代理，我们可以直接手动推进目标方法运行（joinPoint.procced()）

```java
public class LogAspects {

    // @Before：在目标方法（即div方法）运行之前切入，public int com.zsxfa.aop.MathCalculator.div(int, int)这一串就是切入点表达式，指定在哪个方法切入
    @Before("public int com.zsxfa.aop.MathCalculator.*(..)")
    public void logStart() {
        System.out.println("除法运行......@Before，参数列表是：{}");
    }

    // 在目标方法（即div方法）结束时被调用
    @After("public int com.zsxfa.aop.MathCalculator.*(..)")
    public void logEnd() {
        System.out.println("除法结束......@After");
    }

    // 在目标方法（即div方法）正常返回了，有返回值，被调用
    @AfterReturning("public int com.zsxfa.aop.MathCalculator.*(..)")
    public void logReturn() {
        System.out.println("除法正常返回......@AfterReturning，运行结果是：{}");
    }

    // 在目标方法（即div方法）出现异常，被调用
    @AfterThrowing("public int com.zsxfa.aop.MathCalculator.*(..)")
    public void logException() {
        System.out.println("除法出现异常......异常信息：{}");
    }
}
```

`public int com.meimeixia.aop.MathCalculator.*(..)"`，其实它就是切入点表达式，即指定在哪个方法切入。如果要在每一个通知方法上都写上这个，有什么好的方法吗？

如果切入点表达式都一样的情况下，那么我们可以抽取出一个公共的切入点表达式，就像下面这样。

```java
public class LogAspects {
	
	// 如果切入点表达式都一样的情况下，那么我们可以抽取出一个公共的切入点表达式
	@Pointcut("execution(public int com.zsxfa.aop.MathCalculator.*(..))")
	public void pointCut() {}
	/*********代码省略*********/
}
```

pointCut()方法就是抽取出来的一个公共的切入点表达式，其实该方法的方法名随便写啥都行，但是方法体中啥都别写。

那么问题来了，如何在每一个通知方法上引用这个公共的切入点表达式呢？这得分两种情况来讨论，**第一种情况，如果是本类引用**，那么可以像下面这样写。

```java
public class LogAspects {
	
        // 如果切入点表达式都一样的情况下，那么我们可以抽取出一个公共的切入点表达式
        @Pointcut("execution(public int com.zsxfa.aop.MathCalculator.*(..))")
        public void pointCut() {}

        // @Before：在目标方法（即div方法）运行之前切入，public int com.zsxfa.aop.MathCalculator.div(int, int)这一串就是切入点表达式，指定在哪个方法切入
        // @Before("public int com.zsxfa.aop.MathCalculator.*(..)")
        @Before("pointCut()")
        public void logStart() {
            System.out.println("除法运行......@Before，参数列表是：{}");
        }
        /*********代码省略*********/
}
```

**第二种情况，如果是外部类（即其他的切面类）引用，那么就得在通知注解中写方法的全名了**，例如，

```java
public class LogAspects {
	
	// 如果切入点表达式都一样的情况下，那么我们可以抽取出一个公共的切入点表达式
	@Pointcut("execution(public int com.zsxfa.aop.MathCalculator.*(..))")
	public void pointCut() {}
	
	// @Before：在目标方法（即div方法）运行之前切入，public int com.zsxfa.aop.MathCalculator.div(int, int)这一串就是切入点表达式，指定在哪个方法切入
	// @Before("public int com.zsxfa.aop.MathCalculator.*(..)")
	@Before("pointCut()")
	public void logStart() {
		System.out.println("除法运行......@Before，参数列表是：{}");
	}
	
	// 在目标方法（即div方法）结束时被调用
	// @After("pointCut()")
	@After("com.zsxfa.aop.LogAspects.pointCut()")
	public void logEnd() {
		System.out.println("除法结束......@After");
	}
	
	// 在目标方法（即div方法）正常返回了，有返回值，被调用
	@AfterReturning("pointCut()")
	public void logReturn() {
		System.out.println("除法正常返回......@AfterReturning，运行结果是：{}");
	}
	
	// 在目标方法（即div方法）出现异常，被调用
	@AfterThrowing("pointCut()")
	public void logException() {
		System.out.println("除法出现异常......异常信息：{}");
	}
}
```

然后，必须告诉Spring哪个类是切面类，要做到这一点很简单，只需要给切面类上加上一个@Aspect注解即可。

```java
@Aspect
public class LogAspects {
    /*********代码省略*********/
}
```

### （四）将目标类和切面类加入到IOC容器

在com.zsxfa.config包中，新建一个配置类，例如MainConfigOfAOP，并使用@Configuration注解标注这是一个Spring的配置类，同时使用@EnableAspectJAutoProxy注解开启基于注解的AOP模式。在MainConfigOfAOP配置类中，使用@Bean注解将业务逻辑类（目标方法所在类）和切面类都加入到IOC容器中，如下所示。

```java
@Configuration
@EnableAspectJAutoProxy
public class MainConfigOfAOP {

    // 将业务逻辑类（目标方法所在类）加入到容器中
    @Bean
    public MathCalculator calculator() {
        return new MathCalculator();
    }

    // 将切面类加入到容器中
    @Bean
    public LogAspects logAspects() {
        return new LogAspects();
    }
}
```

一定不要忘了给MainConfigOfAOP配置类标注@EnableAspectJAutoProxy注解哟！在Spring中，未来会有很多的@EnableXxx注解，它们的作用都是开启某一项功能，来替换我们以前的那些配置文件。

### （五）测试

首先，在com.zsxfa.test包中创建一个单元测试类，例如IOCTest_AOP，并在该测试类中创建一个test01()方法，如下所示。

```java
public class IOCTest_AOP {
	
	@Test
	public void test01() {
		AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAOP.class);
		
		// 不要自己创建这个对象
		// MathCalculator mathCalculator = new MathCalculator();
		// mathCalculator.div(1, 1);
		
		// 我们要使用Spring容器中的组件
		MathCalculator mathCalculator = applicationContext.getBean(MathCalculator.class);
		mathCalculator.div(1, 1);
		
		// 关闭容器
		applicationContext.close();
	}
}
```

然后，运行以上IOCTest_AOP类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/28/1643335054.png)

可以看到，执行了切面类中的方法，并打印出了相关信息。**但是并没有打印参数列表和运行结果。**

如果需要在切面类中打印出参数列表和运行结果，那么该怎么办呢？

要想打印出参数列表和运行结果，就需要对LogAspects切面类中的方法进行优化，优化后的结果如下所示。

```java
@Aspect
public class LogAspects {

    // 如果切入点表达式都一样的情况下，那么我们可以抽取出一个公共的切入点表达式
    // 1. 本类引用
    // 2. 如果是外部类，即其他的切面类引用，那就在这@After("...")写的是方法的全名，而我们就要把切入点写在这儿@Pointcut("...")
    @Pointcut("execution(public int com.zsxfa.aop.MathCalculator.*(..))")
    public void pointCut() {}

    // @Before：在目标方法（即div方法）运行之前切入，public int com.meimeixia.aop.MathCalculator.div(int, int)这一串就是切入点表达式，指定在哪个方法切入
    // @Before("public int com.meimeixia.aop.MathCalculator.*(..)")
    @Before("pointCut()")
    public void logStart(JoinPoint joinPoint) {
        // System.out.println("除法运行......@Before，参数列表是：{}");

        Object[] args = joinPoint.getArgs(); // 拿到参数列表，即目标方法运行需要的参数列表
        System.out.println(joinPoint.getSignature().getName() + "运行......@Before，参数列表是：{" + Arrays.asList(args) + "}");
    }

    // 在目标方法（即div方法）结束时被调用
    // @After("pointCut()")
    @After("com.zsxfa.aop.LogAspects.pointCut()")
    public void logEnd(JoinPoint joinPoint) {
        // System.out.println("除法结束......@After");

        System.out.println(joinPoint.getSignature().getName() + "结束......@After");
    }

    // 在目标方法（即div方法）正常返回了，有返回值，被调用
    // @AfterReturning("pointCut()")
    @AfterReturning(value="pointCut()", returning="result") // returning来指定我们这个方法的参数谁来封装返回值
    /*
     * 如果方法正常返回，我们还想拿返回值，那么返回值又应该怎么拿呢？
     */
    public void logReturn(JoinPoint joinPoint, Object result) { // 一定要注意：JoinPoint这个参数要写，一定不能写到后面，它必须出现在参数列表的第一位，否则Spring也是无法识别的，就会报错
        // System.out.println("除法正常返回......@AfterReturning，运行结果是：{}");
        System.out.println(joinPoint.getSignature().getName() + "正常返回......@AfterReturning，运行结果是：{" + result + "}");
    }

    // 在目标方法（即div方法）出现异常，被调用
    @AfterThrowing("pointCut()")
    public void logException() {
        System.out.println("除法出现异常......异常信息：{}");
    }
}
```

**这里，需要注意的是，JoinPoint参数一定要放在参数列表的第一位，否则Spring是无法识别的，那自然就会报错了。**

此时，我们再次运行IOCTest_AOP类中的test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/28/1643335365.png)

如果目标方法运行时出现了异常，而我们又想拿到这个异常信息，那么该怎么办呢？只须对LogAspects切面类中的logException()方法进行优化即可，优化后的结果如下所示。

```java
// 在目标方法（即div方法）出现异常，被调用
// @AfterThrowing("pointCut()")
@AfterThrowing(value="pointCut()", throwing="exception")
public void logException(JoinPoint joinPoint, Exception exception) {
    // System.out.println("除法出现异常......异常信息：{}");
    
    System.out.println(joinPoint.getSignature().getName() + "出现异常......异常信息：{" + exception + "}");
}
```

可以看到，JoinPoint参数是放在了参数列表的第一位。

接下来，我们就在MathCalculator类的div()方法中模拟抛出一个除零异常，来测试下异常情况，如下所示。

```java
public class IOCTest_AOP {
	
	@Test
	public void test01() {
		AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfigOfAOP.class);
		
		// 不要自己创建这个对象
		// MathCalculator mathCalculator = new MathCalculator();
		// mathCalculator.div(1, 1);
		
		// 我们要使用Spring容器中的组件
		MathCalculator mathCalculator = applicationContext.getBean(MathCalculator.class);
		mathCalculator.div(1, 0);
		
		// 关闭容器
		applicationContext.close();
	}
}
```

此时，我们运行以上test01()方法，输出的结果信息如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/28/1643335478.png)

可以看到，正确的输出了切面中打印的信息，包括除零异常的信息。

至此，我们的AOP测试环境就搭建成功了。

### （六）小结

搭建AOP测试环境时，虽然步骤繁多，但是我们只要牢牢记住以下三点，就会无往而不利了。

1. 将切面类和业务逻辑组件（目标方法所在类）都加入到容器中，并且要告诉Spring哪个类是切面类（标注了@Aspect注解的那个类）。
2. 在切面类上的每个通知方法上标注通知注解，告诉Spring何时何地运行，当然最主要的是要写好切入点表达式，这个切入点表达式可以参照官方文档来写。
3. **开启基于注解的AOP模式，即加上@EnableAspectJAutoProxy注解，这是最关键的一点。**

# 2. @EnableAspectJAutoProxy注解

在配置类上添加@EnableAspectJAutoProxy注解，便能够开启注解版的AOP功能。也就是说，如果要使注解版的AOP功能起作用的话，那么就得需要在配置类上添加@EnableAspectJAutoProxy注解。我们先来看下@EnableAspectJAutoProxy注解的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643460460.png)

从源码中可以看出，@EnableAspectJAutoProxy注解使用@Import注解给容器中引入了AspectJAutoProxyRegister组件。那么，这个AspectJAutoProxyRegistrar组件又是什么呢？我们继续点进去到AspectJAutoProxyRegistrar类的源码中，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643460550.png)

可以看到AspectJAutoProxyRegistrar类实现了ImportBeanDefinitionRegistrar接口。我们再点进去到ImportBeanDefinitionRegistrar接口的源码中，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643460641.png)

看到ImportBeanDefinitionRegistrar这个接口,也就是说，我们可以通过ImportBeanDefinitionRegistrar接口实现将自定义的组件添加到IOC容器中。

也就是说， **@EnableAspectJAutoProxy注解使用AspectJAutoProxyRegistrar对象自定义组件，并将相应的组件添加到了IOC容器中。**

那么，@EnableAspectJAutoProxy注解使用AspectJAutoProxyRegistrar对象向容器中注册了一个什么bean呢？

## 调试Spring源码

首先，我们需要给这个AspectJAutoProxyRegistrar类打一个断点，断点就打在该类的registerBeanDefinitions()方法处，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643460919.png)

然后，我们以debug的方式来运行IOCTest_AOP类中的test01()方法。运行后程序进入到断点位置，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643461013.png)

可以看到，程序已经暂停在断点位置了。

我们还可以看到，在AspectJAutoProxyRegistrar类的registerBeanDefinitions()方法里面，首先调用了AopConfigUtils类的registerAspectJAnnotationAutoProxyCreatorIfNecessary()方法来注册registry，单看registerAspectJAnnotationAutoProxyCreatorIfNecessary()方法也不难理解，字面含义就是：如果需要的话，那么就注册一个AspectJAnnotationAutoProxyCreator组件。

接着，我们进入到AopConfigUtils类的registerAspectJAnnotationAutoProxyCreatorIfNecessary()方法中，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643461355.png)

在AopConfigUtils类的registerAspectJAnnotationAutoProxyCreatorIfNecessary()方法中，直接调用了重载的registerAspectJAnnotationAutoProxyCreatorIfNecessary()方法。我们继续跟进代码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643461452.png)

可以看到在重载的registerAspectJAnnotationAutoProxyCreatorIfNecessary()方法中直接调用了registerOrEscalateApcAsRequired()方法，并且在registerOrEscalateApcAsRequired()方法中，传入了AnnotationAwareAspectJAutoProxyCreator.class对象。

我们继续跟进代码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643461704.png)

我们可以看到，在registerOrEscalateApcAsRequired()方法中，接收到的Class对象的类型为org.springframework.aop.aspectj.annotation.AnnotationAwareAspectJAutoProxyCreator。

除此之外，我们还可以看到，在registerOrEscalateApcAsRequired()方法中会做一个判断，即首先判断registry（也就是IOC容器）是否包含名称为org.springframework.aop.config.internalAutoProxyCreator的bean，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643461898.png)

如果registry中包含名称为org.springframework.aop.config.internalAutoProxyCreator的bean，那么就进行相应的处理。从Spring的源码来看，就是将名称为org.springframework.aop.config.internalAutoProxyCreator的bean从容器中取出，并且判断cls对象的name值和apcDefinition的beanClassName值是否相等，**若不相等**，则获取apcDefinition和cls它俩的优先级，如果apcDefinition的优先级小于cls的优先级，那么将apcDefinition的beanClassName设置为cls的name值。相对来说，理解起来还是比较简单的。

由于我们这里是第一次运行程序，容器中应该还没有包含名称为org.springframework.aop.config.internalAutoProxyCreator的bean，所以此时并不会进入到if判断条件中。我们继续往下看代码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643462059.png)

这儿，会使用RootBeanDefinition来创建一个bean的定义信息（即beanDefinition），并且将org.springframework.aop.aspectj.annotation.AnnotationAwareAspectJAutoProxyCreator的Class对象作为参数传递进来。

我们继续往下看代码，最终在AopConfigUtils类的registerOrEscalateApcAsRequired()方法中，会通过registry调用registerBeanDefinition()方法注册组件，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643462629.png)

注册的组件的类型是org.springframework.aop.aspectj.annotation.AnnotationAwareAspectJAutoProxyCreator，组件的名字是org.springframework.aop.config.internalAutoProxyCreator。

我们继续往下看代码，最终会回到AspectJAutoProxyRegistrar类的registerBeanDefinitions()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643462778.png)

接下来，我们继续往下看代码，即查看AspectJAutoProxyRegistrar类中的registerBeanDefinitions()方法的源码，如下所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643462866.png)

可以看到，通过AnnotationConfigUtils类的attributesFor()方法来获取@EnableAspectJAutoProxy注解的信息。接着，就是判断proxyTargetClass属性的值是否为true，若为true则调用AopConfigUtils类的forceAutoProxyCreatorToUseClassProxying()方法；继续判断exposeProxy属性的值是否为true，若为true则调用AopConfigUtils类的forceAutoProxyCreatorToExposeProxy()方法，其实就是暴露一些什么代理的这些bean。

**综上，向Spring的配置类上添加@EnableAspectJAutoProxy注解之后，会向IOC容器中注册AnnotationAwareAspectJAutoProxyCreator，翻译过来就叫注解装配模式的AspectJ切面自动代理创建器。**

这个AnnotationAwareAspectJAutoProxyCreator又是什么呢？别急，后面我们会核心研究它，现在我们只要知道在容器中注册了这样一个AnnotationAwareAspectJAutoProxyCreator组件就行了，至于注册的这个组件有什么功能呢？后面我们会继续研究它！其实，只要我们研究出来了，那么这个AOP的原理我们就彻底地知道了。

在研究它之前，我们来看下AnnotationAwareAspectJAutoProxyCreator类的结构图。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/29/1643463406.png)

可以看到，它继承了很多很多东东，我们简单梳理下AnnotationAwareAspectJAutoProxyCreato类的核心继承关系，如下所示。

- AnnotationAwareAspectJAutoProxyCreator
  - AspectJAwareAdvisorAutoProxyCreator（父类）
    - AbstractAdvisorAutoProxyCreator（父类）
      - AbstractAutoProxyCreator（父类）
        - implements **SmartInstantiationAwareBeanPostProcessor**和**BeanFactoryAware**（两个接口）

查看继承关系可以发现，此类实现了Aware与BeanPostProcessor接口，这两个接口都和Spring bean的初始化有关，由此可以推测此类的主要处理方法都来自于这两个接口中的实现方法。

# 3. AnnotationAwareAspectJAutoProxyCreator组件

通过上面的继承关系，我们也知道了，它最终会实现两个接口，分别是：

- BeanPostProcessor：后置处理器，即在bean初始化完成前后做些事情
- BeanFactoryAware：自动注入BeanFactory

也就是说，AnnotationAwareAspectJAutoProxyCreator不仅是一个后置处理器，还是一个BeanFactoryAware接口的实现类。那么我们就来分析它作为后置处理器，到底做了哪些工作，以及它作为BeanFactoryAware接口的实现类，又做了哪些工作，只要把这个分析清楚，AOP的整个原理就差不多出来了。

## 为AnnotationAwareAspectJAutoProxyCreator组件里面和后置处理器以及Aware接口有关的方法打上断点

接下来，我们就要为AnnotationAwareAspectJAutoProxyCreator这个组件里面和后置处理器以及Aware接口有关的方法都打上断点，看一下它们何时运行，以及都做了些什么事。

在打断点之前，我们还是得小心分析一下，因为AnnotationAwareAspectJAutoProxyCreator这个组件的继承关系还是蛮复杂的。由于是从AbstractAutoProxyCreator这个抽象类开始实现SmartInstantiationAwareBeanPostProcessor以及BeanFactoryAware这俩接口的，如果我们直接来AnnotationAwareAspectJAutoProxyCreator这个类里面找与Aware接口以及BeanPostProcessor接口有关的方法，是极有可能找不到的，所以我们还是得从它的最开始的父类（即AbstractAutoProxyCreator）开始分析。

我们找到该抽象类，并在里面查找与Aware接口以及BeanPostProcessor接口有关的方法，结果都是可以找到的。该抽象类中的setBeanFactory()方法就是与Aware接口有关的方法，因此我们将断点打在该方法上，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643544318.png)

此外，我们还得找到该抽象类中与BeanPostProcessor接口有关的方法，即只要发现有与后置处理器相关的逻辑，就给所有与后置处理器有关的逻辑都打上断点。打的断点有两处，一处是在postProcessBeforeInstantiation()方法上，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643544399.png)

一处是在postProcessAfterInitialization()方法上，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643544475.png)

接下来，我们再来看它的子类（即AbstractAdvisorAutoProxyCreator），从顶层开始一点一点往上分析。

在该抽象类中，我们只能找到一个与Aware接口有关的方法，即setBeanFactory()方法，虽然父类有setBeanFactory()方法，但是在这个子类里面已经把它重写了，因此最终调用的应该就是它。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643544551.png)

大家注意，在重写的时候，在setBeanFactory()方法里面会调用一个initBeanFactory()方法。除此之外，该抽象类中就没有跟后置处理器有关的方法了。

接下来，我们就应该来看AspectJAwareAdvisorAutoProxyCreator这个类了，但由于这个类里面没有跟BeanPostProcessor接口有关的方法，所以我们就不必看这个类了，略过。

接下来，我们就要来看最顶层的类了，即AnnotationAwareAspectJAutoProxyCreator。查看该类时，发现有这样一个initBeanFactory()方法，我们在该方法上打上一个断点就好，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643544663.png)

为什么在该类里面会有这个方法呢？因为我们在它的父类里面会调用setBeanFactory()方法，而在该方法里面又会调用initBeanFactory()方法，虽然父类里面有写，但是又被它的子类给重写了，所以说相当于父类中的setBeanFactory()方法还是得调用它。

那在该类中还有没有跟后置处理器有关的方法呢？没有了。

综上，我们通过简单的人工分析，为这个AnnotationAwareAspectJAutoProxyCreator类中有关后置处理器以及自动装配BeanFactoryAware接口的这些方法都打上了一些断点，接下来，我们就要来进行debug调试分析了。

不过在这之前，我们还得为MainConfigOfAOP配置类中的如下两个方法打上断点。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545054.png)

然后，我们就可以正式以debug模式来运行IOCTest_AOP测试类了，顺便分析一下整个流程。

## 创建和注册AnnotationAwareAspectJAutoProxyCreator的过程

以debug模式来运行IOCTest_AOP测试类之后，会先来到AbstractAdvisorAutoProxyCreator类的setBeanFactory()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545248.png)

究竟是怎么来到这个setBeanFactory()方法中的啊？我们这就来分析一下，在左上角的方法调用栈中，仔细查找，就会在前面找到一个test01()方法，它其实就是IOCTest_AOP测试类中的测试方法，我们就从该方法开始分析，然后详细记录一下方法调用栈中整个的方法调用流程。

鼠标单击方法调用栈中的那个test01()方法，此时，我们会进入到IOCTest_AOP测试类中的test01()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545315.png)

可以看到这一步是传入主配置类来创建IOC容器，怎么创建的呢？我们点击方法调用栈中test01()方法上面的那个方法，就来到下面这个地方了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545389.png)

可以看到，传入主配置类来创建IOC容器使用的是AnnotationConfigApplicationContext类的有参构造器，它具体分为下面三步：

- 首先使用无参构造器创建对象
- 再来把主配置类注册进来
- 最后调用refresh()方法刷新容器，刷新容器就是要把容器中的所有bean都创建出来，也就是说这就像初始化容器一样

接下来，我们来看看容器刷新是怎么做的？我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractApplicationContext抽象类的refresh()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545510.png)

以上refresh()方法中的代码还是蛮多的，所以又截了一张图，如下所示！

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545678.png)

其中，该refresh()方法中有一行非常重要的代码，那就是：

```java
// Register bean processors that intercept bean creation.
registerBeanPostProcessors(beanFactory);
```

即注册bean的后置处理器。它的作用是什么呢？我们可以看一下它上面的注释，它就是用来方便拦截bean的创建的，那么这个后置处理器的注册逻辑又是什么样的呢？

我们继续跟进方法调用栈，可以看到现在是定位到了如下图所示的地方。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545780.png)

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到PostProcessorRegistrationDelegate类的registerBeanPostProcessors()方法中了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545893.png)

以上registerBeanPostProcessors()方法中的代码还是蛮多的，所以又截了一张图，如下所示！

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643546176.png)

这个方法太长啊，但是没关系，我来帮大家分析一下，到底是怎么注册bean的后置处理器的。

1. 先按照类型拿到IOC容器中所有需要创建的后置处理器，即先获取IOC容器中已经定义了的需要创建对象的所有BeanPostProcessor。这可以从如下这行代码中得知：

   ```java
   String[] postProcessorNames = beanFactory.getBeanNamesForType(BeanPostProcessor.class, true, false);
   ```

   你可能要问了，为什么IOC容器中会有一些已定义的BeanPostProcessor呢？这是因为在前面创建IOC容器时，需要先传入配置类，而我们在解析配置类的时候，由于这个配置类里面有一个@EnableAspectJAutoProxy注解，对于该注解，我们之前也说过，它会为我们容器中注册一个AnnotationAwareAspectJAutoProxyCreator（后置处理器），这还仅仅是这个@EnableAspectJAutoProxy注解做的事，除此之外，容器中还有一些默认的后置处理器的定义。

   所以，程序运行到这，容器中已经有一些我们将要用的后置处理器了，只不过现在还没创建对象，都只是一些定义，也就是说容器中有哪些后置处理器。

2. 继续往下看这个registerBeanPostProcessors()方法，可以看到它里面还有其他的逻辑，如下所示：

   ```java
   beanFactory.addBeanPostProcessor(new BeanPostProcessorChecker(beanFactory, beanProcessorTargetCount));
   ```

   说的是给beanFactory中额外还加了一些其他的BeanPostProcessor，也就是说给容器中加别的BeanPostProcessor。

3. 继续往下看这个registerBeanPostProcessors()方法，发现它里面还有这样的注释，如下所示：

   ```java
   // Separate between BeanPostProcessors that implement PriorityOrdered,
   // Ordered, and the rest.
   List<BeanPostProcessor> priorityOrderedPostProcessors = new ArrayList<BeanPostProcessor>();
   /************下面是代码，省略************/
   ```

   说的是分离这些BeanPostProcessor，看哪些是实现了PriorityOrdered接口的，哪些又是实现了Ordered接口的，包括哪些是原生的没有实现什么接口的。所以，在这儿，对这些BeanPostProcessor还做了一些处理，所做的处理看以下代码便一目了然。

   ```java
   for (String ppName : postProcessorNames) {
       if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
           BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
           priorityOrderedPostProcessors.add(pp);
           if (pp instanceof MergedBeanDefinitionPostProcessor) {
               internalPostProcessors.add(pp);
           }
       }
       else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
           orderedPostProcessorNames.add(ppName);
       }
       else {
           nonOrderedPostProcessorNames.add(ppName);
       }
   }
   ```

   拿到IOC容器中所有这些BeanPostProcessor之后，是怎么处理的呢？它是来看我们这个BeanPostProcessor是不是实现了PriorityOrdered接口，我们不妨看一下PriorityOrdered接口的源码，如下图所示。

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643546886.png)

   好了，现在我们知道了这样一个结论，那就是：**IOC容器中的那些BeanPostProcessor可以实现PriorityOrdered以及Ordered这些接口来定义它们工作的优先级，即谁先前谁先后。**

   回到代码中，就不难看到，它是在这儿将这些BeanPostProcessor做了一下划分，如果BeanPostProcessor实现了PriorityOrdered接口，那么就将其保存在名为priorityOrderedPostProcessors的List集合中，并且要是该BeanPostProcessor还是MergedBeanDefinitionPostProcessor这种类型的，则还得将其保存在名为internalPostProcessors的List集合中。

4. 继续往下看这个registerBeanPostProcessors()方法，主要是看其中的注释，不难发现有以下三步：

   1. 优先注册实现了PriorityOrdered接口的BeanPostProcessor
   2. 再给容器中注册实现了Ordered接口的BeanPostProcessor
   3. 最后再注册没实现优先级接口的BeanPostProcessor

   那么，所谓的注册BeanPostProcessor又是什么呢？我们还是来到程序停留的地方，为啥子程序会停留在这儿呢？因为咱们现在即将要创建的名称为internalAutoProxyCreator的组件（其实它就是我们之前经常讲的AnnotationAwareAspectJAutoProxyCreator）实现了Ordered接口，这只要查看AnnotationAwareAspectJAutoProxyCreator类的源码便知，一级一级地往上查.

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643545893.png)

   可以看到，是先拿到要注册的BeanPostProcessor的名字，然后再从beanFactory中来获取。

接下来，我们就要获取相应名字的BeanPostProcessor了，怎么获取呢？继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractBeanFactory抽象类的getBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548074.png)

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractBeanFactory抽象类的doGetBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548115.png)

这个方法特别特别的长，这儿我就不再详细分析它了，只须关注程序停留的这行代码即可。这行代码的意思是调用getSingleton()方法来获取单实例的bean，但是呢，IOC容器中第一次并不会有这个bean，所以第一次获取它肯定是会有问题的。

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了DefaultSingletonBeanRegistry类的getSingleton()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548171.png)

也就是说如果从IOC容器中第一次获取单实例的bean出现问题，也即获取不到时，那么就会调用singletonFactory的getObject()方法。

我们继续跟进方法调用栈，如下图所示，可以看到现在又定位到了AbstractBeanFactory抽象类的doGetBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548327.png)

可以发现，现在就是来创建bean的，也就是说如果获取不到那么就创建bean。**咱们现在就是需要注册BeanPostProcessor，说白了，实际上就是创建BeanPostProcessor对象，然后保存在容器中。**

那么接下来，我们就来看看是如何创建出名称为internalAutoProxyCreator的BeanPostProcessor的，它的类型其实就是我们之前经常说的AnnotationAwareAspectJAutoProxyCreator。我们就以它为例，来看看它这个对象是怎么创建出来的。

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的createBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548415.png)

接着再跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的doCreateBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548509.png)

程序停留在这儿，就是在初始化bean实例，说明bean实例已经创建好了，如果你要不信的话，那么可以往前翻阅该doCreateBean()方法，这时你应该会看到一个createBeanInstance()方法，说的就是bean实例的创建。创建的是哪个bean实例呢？就是名称为internalAutoProxyCreator的实例，该实例的类型就是我们之前经常说的AnnotationAwareAspectJAutoProxyCreator，即创建这个类型的实例。创建好了之后，就在程序停留的地方进行初始化。

所以，整个的过程就应该是下面这个样子的：

1. 首先创建bean的实例
2. 然后给bean的各种属性赋值（即调用populateBean()方法）
3. 接着初始化bean（即调用initializeBean()方法），这个初始化bean其实特别地重要，因为我们这个后置处理器就是在bean初始化的前后进行工作的。

接下来，我们就来看看这个bean的实例是如何初始化的。继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的initializeBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548609.png)

详细分析一下**初始化bean的流程**。

1. 首先我们进入invokeAwareMethods()这个方法里面看一下，如下图所示。

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548674.png)

   其实，这个方法是来判断我们这个bean对象是不是Aware接口的，如果是，并且它还是BeanNameAware、BeanClassLoaderAware以及BeanFactoryAware这几个Aware接口中的其中一个，那么就调用相关的Aware接口方法，即处理Aware接口的方法回调。

   现在当前的这个bean叫internalAutoProxyCreator，并且这个bean对象已经被创建出来了，创建出来的这个bean对象之前我们也分析过，它是有实现BeanFactoryAware接口的，故而会调用相关的Aware接口方法，这也是程序为什么会停留在invokeAwareMethods()这个方法的原因。

2. 还是回到AbstractAutowireCapableBeanFactory抽象类的initializeBean()方法中，即程序停留的地方。如果invokeAwareMethods()这个方法执行完了以后，那么后续又会发生什么呢？

   往下翻阅initializeBean()方法，会发现有一个叫applyBeanPostProcessorsBeforeInitialization的方法，如下图所示。

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548853.png)

   这个方法调用完以后，会返回一个被包装的bean。

   该方法的意思其实就是应用后置处理器的postProcessBeforeInitialization()方法。我们可以进入该方法中去看一看，到底是怎么应用后置处理器的postProcessBeforeInitialization()方法的？

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548915.png)

   可以看到，它是拿到所有的后置处理器，然后再调用后置处理器的postProcessBeforeInitialization()方法，也就是说bean初始化之前后置处理器的调用在这儿。

3. 还是回到程序停留的地方，继续往下翻阅initializeBean()方法，你会发现还有一个叫invokeInitMethods的方法，即执行自定义的初始化方法。

   这个自定义的初始化方法呢，你可以用@bean注解来定义，指定一下初始化方法是什么，销毁方法又是什么，这个我们之前都说过了。

4. 自定义的初始化方法执行完以后，又有一个叫applyBeanPostProcessorsAfterInitialization的方法，该方法的意思其实就是应用后置处理器的postProcessAfterInitialization()方法。我们可以进入该方法中去看一看，到底是怎么应用后置处理器的postProcessAfterInitialization()方法的？

   ![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549053.png)

   依旧是拿到所有的后置处理器，然后再调用后置处理器的postProcessAfterInitialization()方法。

   所以，后置处理器的这两个postProcessBeforeInitialization()与postProcessAfterInitialization()方法前后的执行，就是在这块体现的。我们在这儿也清楚地看到了。

调用initializeBean()方法初始化bean的时候，还得执行那些Aware接口的方法，那到底怎么执行呢？正好我们知道，当前的这个bean它确实是实现了BeanFactoryAware接口。因此我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的invokeAwareMethods()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643548674.png)

再继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAdvisorAutoProxyCreator抽象类的setBeanFactory()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549212.png)

可以看到现在调用的是AbstractAdvisorAutoProxyCreator抽象类中的setBeanFactory()方法。我们要创建的是AnnotationAwareAspectJAutoProxyCreator对象，但是调用的却是它父类的setBeanFactory()方法。

接下来，按下`F6`快捷键让程序往下运行，父类的setBeanFactory()方法便会被调用，再按下`F6`快捷键让程序往下运行，一直让程序运行到如下图所示的这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549315.png)

可以看到父类的setBeanFactory()方法被调用完了。然后按下`F6`快捷键继续让程序往下运行，这时会运行到如下这行代码处。

```java
initBeanFactory((ConfigurableListableBeanFactory) beanFactory);
```

该initBeanFactory()方法就是用来初始化BeanFactory的。我们按下F5快捷键进入到当前方法内部，如下图所示，可以看到调用到了AnnotationAwareAspectJAutoProxyCreator这个类的initBeanFactory()方法中了，即调到了我们要给容器中创建的AspectJ自动代理创建器的initBeanFactory()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549392.png)

接着按下`F6`快捷键继续让程序往下运行，运行完该方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549506.png)

可以看到这个initBeanFactory()方法创建了两个东西，一个叫ReflectiveAspectJAdvisorFactory，还有一个叫BeanFactoryAspectJAdvisorsBuilderAdapter，它相当于把之前创建的aspectJAdvisorFactory以及beanFactory重新包装了一下，就只是这样。

至此，整个这么一个流程下来以后，咱们的这个BeanPostProcessor，我们是以AnnotationAwareAspectJAutoProxyCreator（就是@EnableAspectJAutoProxy这个注解核心导入的BeanPostProcessor）为例来讲解的，就创建成功了。并且还调用了它的initBeanFactory()方法得到了一些什么aspectJAdvisorFactory和aspectJAdvisorsBuilder，这两个东西大家知道一下就行了。至此，整个initBeanFactory()方法我们就说完了，也就是说我们整个的后置处理器的注册以及创建过程就说完了。

我们还是回过头回顾一下，一开始的这行代码是用来注册后置处理器。

```java
// Register bean processors that intercept bean creation.
registerBeanPostProcessors(beanFactory);
```

应该知道，我们是以AnnotationAwareAspectJAutoProxyCreator为例来讲解的，现在你也应该知道整个后置处理器的创建以及注册流程了。

此刻，后置处理器已经在容器中注册进来了。所谓的注册又是什么呢？接下来，我们可以再来看一下，按下`F6`快捷键继续让程序往下运行，一直让程序运行到AbstractAutowireCapableBeanFactory抽象类的initializeBean()方法中的如下这行代码处。

```java
Object wrappedBean = bean;
```

紧接着就是应用各种什么applyBeanPostProcessorsBeforeInitialization()方法或者applyBeanPostProcessorsAfterInitialization()方法了，我们继续按下F6快捷键让程序往下运行，一直让程序运行到如下图所示的这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549770.png)

可以看到咱们要创建的后置处理器（即AnnotationAwareAspectJAutoProxyCreator）总算是创建完了。

继续按下`F6`快捷键让程序往下运行，一直让程序运行到如下图所示的这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549828.png)

上面这行代码的意思是说，后置处理器创建完以后会添加到我们已创建的那个bean集合里面

继续按下`F6`快捷键让程序往下运行，一直让程序运行到如下图所示的230这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643549906.png)

可以看到，咱们这个BeanPostProcessor（即AnnotationAwareAspectJAutoProxyCreator）创建完了以后，会放进了一个叫什么internalPostProcessors的这个集合里面。

继续按下`F6`快捷键让程序往下运行，会调用sortPostProcessors()方法按照优先级给这些后置处理器们排一个序，程序再往下运行，就会调用到registerBeanPostProcessors()方法了，进到该方法中去看一下。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/30/1643550107.png)

现在该知道所谓的注册是什么了吧😂！就是**拿到所有的BeanPostProcessor，然后调用beanFactory的addBeanPostProcessor()方法将BeanPostProcessor注册到BeanFactory中。**

至此，整个BeanPostProcessor的创建以及注册过程，我们也就说完了

# 4. BeanFactory的初始化

AnnotationAwareAspectJAutoProxyCreator后置处理器之后，接下来就得完成BeanFactory的初始化工作了。

## 完成BeanFactory的初始化工作

我们还是以debug模式来运行IOCTest_AOP测试类，这时，应该还是会来到AbstractAdvisorAutoProxyCreator类的setBeanFactory()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643621346.png)

在上一讲中，我们是从test01()方法开始一步一步研究慢慢分析到这儿的，所以这儿就不再重复地讲一遍了。那接下来该怎么办呢？我们按下`F8`快捷键直接运行到下一个断点，如下图所示，可以看到现在是定位到了AbstractAutoProxyCreator抽象类的setBeanFactory()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643621428.png)

然后继续按下`F8`快捷键运行直到下一个断点，一直运行到如下图所示的这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643621501.png)

可以看到程序现在是停留在了AbstractAutoProxyCreator类的postProcessBeforeInstantiation()方法中，不过从方法调用栈中我们可以清楚地看到现在其实调用的是AnnotationAwareAspectJAutoProxyCreator的postProcessBeforeInstantiation()方法。

这个方法大家一定要引起注意，它跟我们之前经常讲到的后置处理器中的方法是有区别的。你不妨看一下BeanPostProcessor接口的源码，如下图所示，它里面有一个postProcessbeforeInitialization()方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643621635.png)

而现在这个方法是叫postProcessBeforeInstantiation

你可能要问了，AnnotationAwareAspectJAutoProxyCreator它本身就是一个后置处理器，为何其中的方法叫postProcessBeforeInstantiation，而不是叫postProcessbeforeInitialization呢？因为后置处理器跟为后置处理器是不一样的，当前我们要用到的这个后置处理器（即**AnnotationAwareAspectJAutoProxyCreator**）实现的是一个叫**SmartInstantiationAwareBeanPostProcessor**的接口，而该接口继承的是**InstantiationAwareBeanPostProcessor**接口（它又继承了**BeanPostProcessor**接口），也就是说，**AnnotationAwareAspectJAutoProxyCreator**虽然是一个**BeanPostProcessor**，但是它却是**InstantiationAwareBeanPostProcessor**这种类型的，而**InstantiationAwareBeanPostProcessor**接口中声明的方法就叫**postProcessBeforeInstantiation**。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643621843.png)

故而程序就停留到了AbstractAutoProxyCreator类的postProcessBeforeInstantiation()方法中。

那么你又要问了，为什么会来到这儿呢？我们同样可以仿照前面来大致地来探究一下，在左上角的方法调用栈中，仔细查找，就会在前面找到一个test01()方法，它其实就是IOCTest_AOP测试类中的测试方法，我们就从该方法开始分析。

鼠标单击方法调用栈中的那个test01()方法，此时，我们会进入到IOCTest_AOP测试类中的test01()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643621937.png)

可以看到这一步还是传入主配置类来创建IOC容器，依旧会调用refresh()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622011.png)

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractApplicationContext抽象类的refresh()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622067.png)

可以看到，在这儿会调用finishBeanFactoryInitialization()方法，这是用来初始化剩下的单实例bean的。而在该方法前面，有一个叫registerBeanPostProcessors的方法，它是用来注册后置处理器的，这个方法在上一讲中，我已经讲得够透彻了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622219.png)

注册完后置处理器之后，接下来就来到了finishBeanFactoryInitialization()方法处，以完成BeanFactory的初始化工作。所谓的完成BeanFactory的初始化工作，其实就是来创建剩下的单实例bean。为什么叫剩下的呢？因为IOC容器中的这些组件，比如一些BeanPostProcessor，早都已经在注册的时候就被创建了，所以会留一下没被创建的组件，让它们在这儿进行创建。

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractApplicationContext抽象类的finishBeanFactoryInitialization()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622387.png)

也就是说，这儿会继续调用preInstantiateSingletons()方法来创建剩下的单实例bean。

继续跟进方法调用栈，如下图所示，可以看到现在是定位到了DefaultListableBeanFactory类的preInstantiateSingletons()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622494.png)

在这儿会调用getBean()方法来获取一个bean，那获取的是哪个bean呢？获取的是名称为`org.springframework.context.event.internalEventListenerProcessor`的bean，它跟我们目前的研究没什么关系。

既然没有关系，那为何还要获取这个bean呢？往前翻阅preInstantiateSingletons()方法，可以看到有一个for循环，它是来遍历一个beanNames的List集合的，这个beanNames又是什么呢？很明显它是一个List<String>集合，它里面保存的是容器中所有bean定义的名称，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622739.png)

所以，接下来，我们就可以讲讲完成BeanFactory的初始化工作的第一步了。

## 完成BeanFactory的初始化工作的第一步

遍历获取容器中所有的bean，并依次创建对象，注意是依次调用getBean()方法来创建对象的。

此刻，咱们是来到了第一个bean的创建，只不过它跟我们目前的研究没什么关系。我们可以以它的创建为例来看一下这个bean到底是怎么来创建的。

我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractBeanFactory抽象类的getBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622844.png)

再继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractBeanFactory抽象类的doGetBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643622932.png)

可以看到，获取单实例bean调用的是getSingleton()方法，并且会返回一个sharedInstance对象。其实，从该方法上面的注释中也能看出，这儿是来创建bean实例的。

其实呢，在这儿创建之前，sharedInstance变量已经提前声明过了，我们往前翻阅doGetBean()方法，就能看到已声明的sharedInstance变量了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643629500.png)

可以清楚地看到，在如下这行代码处是来第一次获取单实例bean。

```java
// Eagerly check singleton cache for manually registered singletons.
Object sharedInstance = getSingleton(beanName);
```

那到底是怎么获取的呢？其实从注释中可以知道，它会提前先检查单实例的缓存中是不是已经人工注册了一些单实例的bean，若是则获取。

## 完成BeanFactory的初始化工作的第二步

也就是说，这个bean的创建不是说一下就创建好了的，它得**先从缓存中获取当前bean，如果能获取到，说明当前bean之前是被创建过的，那么就直接使用，否则的话再创建。**

往上翻阅AbstractBeanFactory抽象类的doGetBean()方法，可以看到有这样的逻辑：

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643629898.png)

可以看到，单实例bean是能获取就获取，不能获取才创建。**Spring就是利用这个机制来保证我们这些单实例bean只会被创建一次，也就是说只要创建好的bean都会被缓存起来。**

继续跟进方法调用栈，如下图所示，可以看到现在是定位到了DefaultSingletonBeanRegistry类的getSingleton()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643629964.png)

这儿是调用单实例工厂来进行创建单实例bean。

继续跟进方法调用栈，如下图所示，可以看到现在又定位到了AbstractBeanFactory抽象类的doGetBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643630092.png)

可以看到又会调用createBean()方法来进行创建单实例bean。而在该方法前面是bean能获取到就不会再创建了。接下来，我们来看一下createBean()方法有什么好说的。

继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的createBean()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643630172.png)

往上翻阅createBean()方法，发现可以拿到要创建的bean的定义信息，包括要创建的bean的类型是什么，它是否是单实例等等，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643630545.png)

我们还是将关注点放在resolveBeforeInstantiation()方法上，当前程序也是停在了这一行，即473行。

该方法是来解析BeforeInstantiation的，这是啥子意思啊？我们可以看一下该方法上的注释，它是说给后置处理器一个机会，来返回一个代理对象，替代我们创建的目标的bean实例。也就是说，我们希望后置处理器在此能返回一个代理对象，如果能返回代理对象那当然就很好了，直接使用就得了，如果不能那么就得调用doCreateBean()方法来创建一个bean实例了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643630653.png)

我为什么要说这个方法呢？进入该方法里面看看你自然就懂了，点进去之后会发现该方法真的好长好长，我为了让大家能够更加清楚地看到这个方法的全貌，就截了如下一张图。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643631207.png)

其实，这个doCreateBean()方法我们之前看过很多遍了，所做的事情无非就是：

1. 首先创建bean的实例
2. 然后给bean的各种属性赋值
3. 接着初始化bean
   1）先执行Aware接口的方法
   2）应用后置处理器的postProcessBeforeInitialization()方法
   3）执行自定义的初始化方法
   4）应用后置处理器的postProcessAfterInitialization()方法

调用doCreateBean()方法才是真正的去创建一个bean实例。

我们还是来到程序停留的地方，即AbstractAutowireCapableBeanFactory抽象类的第473行。我们希望后置处理器在此能返回一个代理对象，如果能返回代理对象那当然就很好了，直接使用就得了。接下来，我们就要看看resolveBeforeInstantiation()方法里面具体是怎么做的了。

继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的resolveBeforeInstantiation()方法中，既然程序是停留在了此处，那说明并没有走后面调用doCreateBean()方法创建bean实例的流程，而是先来到这儿，希望后置处理器能返回一个代理对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643631593.png)

可以看到，在该方法中，首先会拿到要创建的bean的定义信息，包括要创建的bean的类型是什么，它是否是单实例等等，然后看它是不是已经提前被解析过了什么什么，这儿都不算太重要，我们主要关注如下这几行代码：

```java
bean = applyBeanPostProcessorsBeforeInstantiation(targetType, beanName);
if (bean != null) {
    bean = applyBeanPostProcessorsAfterInitialization(bean, beanName);
}
```

这一块会调用两个方法，一个叫方法叫applyBeanPostProcessorsBeforeInstantiation，另一个方法叫applyBeanPostProcessorsAfterInitialization。

后置处理器会先尝试返回对象，怎么尝试返回呢？可以看到，是调用applyBeanPostProcessorsBeforeInstantiation()方法返回一个对象的，那这个方法是干啥的呢？我们继续跟进方法调用栈，如下图所示，可以看到现在是定位到了AbstractAutowireCapableBeanFactory抽象类的applyBeanPostProcessorsBeforeInstantiation()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643631651.png)

我们发现，它是拿到所有的后置处理器，如果后置处理器是InstantiationAwareBeanPostProcessor这种类型的，那么就执行该后置处理器的postProcessBeforeInstantiation()方法。我为什么要说这个方法呢？因为现在遍历拿到的后置处理器是AnnotationAwareAspectJAutoProxyCreator这种类型的，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643631742.png)

并且前面我也说了，它就是InstantiationAwareBeanPostProcessor这种类型的后置处理器，这种类型的后置处理器中声明的方法就叫postProcessBeforeInstantiation，而不是我们以前学的后置处理器中的叫postProcessbeforeInitialization的方法，也就是说后置处理器跟后置处理器是不一样的。

我们以前就知道，BeanPostProcessor是在bean对象创建完成初始化前后调用的。而在这儿我们也看到了，首先是会有一个判断，即判断后置处理器是不是InstantiationAwareBeanPostProcessor这种类型的，然后再尝试用后置处理器返回对象（当然了，是在创建bean实例之前）。

总之，我们可以得出一个结论：**AnnotationAwareAspectJAutoProxyCreator会在任何bean创建之前，先尝试返回bean的实例。**

最后，我们继续跟进方法调用栈，如下图所示，可以看到终于又定位到了AbstractAutoProxyCreator抽象类的postProcessBeforeInstantiation()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/01/31/1643631807.png)

为什么程序会来到这个方法中呢？想必你也非常清楚了，因为判断后置处理器是不是InstantiationAwareBeanPostProcessor这种类型时，轮到了AnnotationAwareAspectJAutoProxyCreator这个后置处理器，而它正好是InstantiationAwareBeanPostProcessor这种类型的，所以程序自然就会来到它的postProcessBeforeInstantiation()方法中。

呼应前面，我们现在是终于分析到了AnnotationAwareAspectJAutoProxyCreator这个后置处理器的postProcessBeforeInstantiation()方法中，也就是知道了程序是怎么到这儿来的。

最终，我们得出这样一个结论：**AnnotationAwareAspectJAutoProxyCreator在所有bean创建之前，会有一个拦截，因为它是InstantiationAwareBeanPostProcessor这种类型的后置处理器，然后会调用它的postProcessBeforeInstantiation()方法。**

# 5. AnnotationAwareAspectJAutoProxyCreator作为后置处理器

前一讲中，我们一步一步分析到了AbstractAutoProxyCreator抽象类的postProcessBeforeInstantiation()方法中，其实，我们也知道现在调用的其实是AnnotationAwareAspectJAutoProxyCreator类的postProcessBeforeInstantiation()方法。

那么，在这一讲中，我们就来看看**AnnotationAwareAspectJAutoProxyCreator**作为后置处理器，它的**postProcessBeforeInstantiation**()方法都做了些什么。

## AnnotationAwareAspectJAutoProxyCreator作为后置处理器，它的作用是什么呢？

我们还是以debug模式来运行IOCTest_AOP测试类，这时，应该还是会来到AbstractAdvisorAutoProxyCreator类的setBeanFactory()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643718302.png)

这些我们以前说过的方法就不再赘述一遍了。我们就按下`F8`快捷键运行直到下一个断点，一直运行到AbstractAutoProxyCreator类的postProcessBeforeInstantiation()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643718477.png)

我们都知道，AnnotationAwareAspectJAutoProxyCreator是InstantiationAwareBeanPostProcessor这种类型的后置处理器，那么它的作用是什么呢？接下来我们就来分析分析。

## 在每一个bean创建之前，调用postProcessBeforeInstantiation()方法

AnnotationAwareAspectJAutoProxyCreator作为后置处理器，它其中的一个作用就是在每一个bean创建之前，调用其postProcessBeforeInstantiation()方法。

接下来，我们来看看这个方法都做了哪些事情。此刻，是来创建容器中的第一个bean的，即EventListenerMethodProcessor，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643718713.png)

在上一讲中，我们已经知道了，这块是一个循环创建，会循环创建每一个bean。像EventListenerMethodProcessor这样的bean，跟我们要研究的AOP原理没什么关系，所以我们并不关心这个bean的创建。我们主要关心MathCalculator（业务逻辑类）和LogAspects（切面类）这两个bean的创建。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643718810.png)

我们要研究的是这两个bean在创建的时候，AnnotationAwareAspectJAutoProxyCreator这个后置处理器都做了些什么？

我们按下`F8`快捷键运行到下一个断点，可以看到这是在创建第一个bean，即EventListenerMethodProcessor。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643718908.png)

继续按下`F8`快捷键运行到下一个断点，可以看到这是在创建第二个bean，即DefaultEventListenerFactory。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643719136.png)

继续按下`F8`快捷键运行到下一个断点，又调用到了postProcessAfterInitialization()方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643719219.png)

你知道了什么结论了吗？是不是**在每次创建bean的时候，都会先调用postProcessBeforeInstantiation()方法，然后再调用postProcessAfterInitialization()方法**啊！

继续按下`F8`快捷键运行到下一个断点，可以看到这是在创建第三个bean，即MainConfigOfAOP。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643719464.png)

也能看到，在创建这个bean时，先是调用了postProcessBeforeInstantiation()方法，继续按下`F8`快捷键运行到下一个断点，可以看到然后是再调用了postProcessAfterInitialization()方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643719537.png)

要创建的这个bean是我们的主配置类，即MainConfigOfAOP，我们也不需要理它。继续按下`F8`快捷键运行到下一个断点，可以看到这是在创建第四个bean，即MathCalculator，这是我们需要关心的了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643719642.png)

按下`F6`快捷键让程序一步一步往下运行，可以看到先是拿到MathCalculator这个bean的名称（即calculator），然后再来判断名为targetSourcedBeans的Set集合里面是否包含有这个bean的名称，只不过此时该Set集合是一个空集合，接着再来判断名为advisedBeans的Map集合里面是否包含有这个bean的名称。所以，整个的流程应该是下面这样子的。

## 先来判断当前bean是否在advisedBeans中

首先我得说明一点，这里，我们只关心MathCalculator（业务逻辑类）和LogAspects（切面类）这两个bean的创建。

advisedBeans是个什么东西呢？它是一个Map集合，里面保存了所有需要增强的bean的名称。那什么又叫需要增强的bean呢？就是那些业务逻辑类，例如MathCalculator，因为它里面的那些方法是需要切面来切的，所以我们要执行它里面的方法，不能再像以前那么简单地执行了，得需要增强，这就是所谓的需要增强的bean。

当程序运行到如下这行代码时，我们来看一下，名为advisedBeans的Map集合里面是不包含MathCalculator这个bean的名称的，因为我们是第一次来处理这个bean。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720060.png)

也就是说，在这儿会判断当前的MathCalculator这个bean有没有在advisedBeans集合里面。

## 再来判断当前bean是否是基础类型，或者是否是切面（标注了@Aspect注解的）

继续按下`F6`快捷键让程序往下运行，可以看到又会做一个判断，即判断当前bean是否是基础类型，或者是否是标注了@Aspect注解的切面。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720213.png)

什么叫基础类型呢？所谓的基础类型就是当前bean是否是实现了Advice、Pointcut、Advisor以及AopInfrastructureBean这些接口。我们可以点进去isInfrastructureClass()方法里面大概看一看，如下图所示，你现在该知道所谓的基础类型是什么了吧。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720286.png)

其实，除了判断当前bean是否是基础类型之外，还有一个判断，那怎么看到这个判断呢？选中isInfrastructureClass()方法，按下`F5`快捷键进入该方法里面，就能看到这个判断了，即判断当前bean是否是标注了@Aspect注解的切面。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720491.png)

从上图中可以清楚地看到，还有一个叫isAspect的方法，它就是来判断当前bean是否是标注了@Aspect注解的切面的。那么它是怎么来判断的呢？我们可以进入该方法里面去看一看（选中该方法，然后按下`F5`快捷键即可进入），如下图所示，可以看到它是用hasAspectAnnotation()方法来判断当前bean有没有标注@Aspect注解的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720605.png)

很显然，当前的这个bean（即MathCalculator）既不是基础类型，也不是标注了@Aspect注解的切面。所以，按下F6快捷键让程序继续往下运行，运行回postProcessBeforeInstantiation()方法中之后，isInfrastructureClass(beanClass)表达式的值就是false了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720731.png)

## 最后判断是否需要跳过

所谓的跳过，就是说不要再处理这个bean了。那跳过又是怎么判断的呢？我们可以按下`F5`快捷键进入shouldSkip()方法里面去看一看，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643720791.png)

可以看到，它会在这儿执行一堆的业务逻辑，首先是调用findCandidateAdvisors()方法找到候选的增强器的集合。

继续按下`F6`快捷键让程序往下运行，检查candidateAdvisors变量，可以看到现在有4个增强器，什么叫增强器啊？**增强器就是切面里面的那些通知方法。** 而且第一个增强器就是logStart()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721129.png)

第二个增强器是logEnd()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721220.png)

第三个增强器是logReturn()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721307.png)

第四个增强器是logException()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721384.png)

总结：在shouldSkip()方法里面，首先会获取到以上这4个通知方法。也就是说，先来获取候选的增强器。所谓的增强器其实就是切面里面的那些通知方法，只不过，在这儿是把通知方法的详细信息包装成了一个Advisor，并将其存放在了一个List<Advisor>集合中，即增强器的集合，即是说，每一个通知方法都会被认为是一个增强器。

那么，每一个增强器的类型又是什么呢？检查一下candidateAdvisors变量便知，每一个封装通知方法的增强器都是InstantiationModelAwarePointcutAdvisor这种类型的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721590.png)

获取到4个增强器之后，然后会来判断每一个增强器是不是AspectJPointcutAdvisor这种类型，如果是，那么返回true。很显然，每一个增强器并不是这种类型的，而是InstantiationModelAwarePointcutAdvisor这种类型的，因此程序并不会进入到那个if判断语句中。

继续按下`F6`快捷键让程序往下运行，一直运行到shouldSkip()方法中的最后一行代码处，可以看到，在shouldSkip()方法里面，最终会调用父类的shouldSkip()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721694.png)

我们可以按下`F5`快捷键进入父类的shouldSkip()方法里面去看一看，如下图所示，发现它在这儿直接就返回false了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721747.png)

继续按下`F6`快捷键让程序往下运行，一直运行回postProcessBeforeInstantiation()方法中，这时，我们可以知道，if判断语句中的第二个表达式的值就是false。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721854.png)

也就是说，shouldSkip()方法的返回值永远是false，而它就是用来判断是否需要跳过的，所以相当于就是说要跳过了。

好吧，跳过那就跳过吧！那就继续按下`F6`快捷键让程序往下运行，我们还是能看到当前这个bean的名字是叫calculator，而且还会拿到什么自定义的TargetSource，但这跟我们目前的研究没有关系，程序往下运行，最后将会直接返回null。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643721946.png)

然后，按下`F8`快捷键运行到下一个断点，发现这时会来到主配置类的calculator()方法中。此刻，是要调用calculator()方法来创建MathCalculator对象了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643722016.png)

继续按下`F8`快捷键运行到下一个断点，可以发现当我们把MathCalculator对象创建完了以后，在这儿又会调用postProcessAfterInitialization()方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643722079.png)

其实，上面我也已经说过了，**在每次创建bean的时候，都会先调用postProcessBeforeInstantiation()方法，然后再调用postProcessAfterInitialization()方法。**

## 创建完对象以后，调用postProcessAfterInitialization()方法

前面我就已说过，AnnotationAwareAspectJAutoProxyCreator作为后置处理器，它的第一个作用。现在，我就来说说它的第二个作用，即在创建完对象以后，会调用其postProcessAfterInitialization()方法。

我们调用刚才的calculator()方法创建完MathCalculator对象以后，发现又会调用AnnotationAwareAspectJAutoProxyCreator（后置处理器）的postProcessAfterInitialization()方法。那么该方法又做了些什么事呢？

继续按下`F6`快捷键让程序往下运行，我们可以看到当前创建好的MathCalculator对象，并且这个bean的名字就叫calculator，也可以看到在这儿还做了一个判断，即判断名为earlyProxyReferences的Set集合里面是否包含当前bean，在该Set集合里面我们可以看到之前已经代理过了什么，目前该Set集合是一个空集合。这都不是我们要关注的内容，我们重点要关注的内容其实是那个叫wrapIfNecessary的方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643722443.png)

什么情况是需要包装的呢？我们可以按下`F5`快捷键进入该方法里面去看一看，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643722488.png)

我们继续按下`F6`快捷键让程序往下运行，可以看到：

- 首先是拿到MathCalculator这个bean的名称（即calculator），然后再来判断名为targetSourcedBeans的Set集合里面是否包含有这个bean的名称，只不过此时该Set集合是一个空集合。

- 接着再来判断名为advisedBeans的Map集合里面是否包含有当前bean的名称。我在前面也说过了advisedBeans这个东东，它就是一个Map集合，里面保存了所有需要增强的bean的名称。

  由于这儿是第一次来处理当前bean，所以名为advisedBeans的Map集合里面是不包含MathCalculator这个bean的名称的。

- 紧接着再来判断当前bean是否是基础类型，或者是否是切面（即标注了@Aspect注解的）。这儿是怎样来判断的，之前我已经详细地讲过了，故略过。

上面这些东西都不是我们要关注的内容，我们重点要关注的内容其实是下面这个叫getAdvicesAndAdvisorsForBean的方法。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643722676.png)

从该方法上面的注释中可以得知，它是用于创建代理对象的，从该方法的名称上（见名知义），我们也可以知道它是来获取当前bean的通知方法以及那些增强器的。

## 获取当前bean的所有增强器

调用getAdvicesAndAdvisorsForBean()方法获取当前bean的所有增强器，也就是那些通知方法，最终封装成这样一个`Object[] specificInterceptors`数组。

到底是怎么来获取当前bean的所有增强器的呢？我们可以按下`F5`快捷键进入getAdvicesAndAdvisorsForBean()方法里面去看一看，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723203.png)

可以看到，又会调用findEligibleAdvisors()方法来获取MathCalculator这个类型的所有增强器，也可以说成是可用的增强器。它又是怎么获取的呢？我们可以按下F5快捷键进入findEligibleAdvisors()方法里面去看一看，如下图所示，可以看到会先调用一个findCandidateAdvisors()方法来获取候选的所有增强器。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723248.png)

候选的所有增强器，前面我也说过了，有4个，就是切面里面定义的那4个通知方法。

按下`F6`快捷键让程序往下运行，可以看到会调用一个findAdvisorsThatCanApply()方法，见名知义，该方法是来找到那些可用的增强器的，以便可以应用到目标对象里面的目标方法中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723290.png)

现在所要做的事情就是，**找到候选的所有增强器，也就是说是来找哪些通知方法是需要切入到当前bean的目标方法中的。**

怎么找呢？我们继续按下`F5`快捷键进入findAdvisorsThatCanApply()方法里面去看一看，如下图所示，可以看到它是用AopUtils工具类来找到所有能用的增强器（通知方法）的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723356.png)

又是怎么找的呢？我们继续按下`F5`快捷键进入AopUtils工具类的findAdvisorsThatCanApply()方法里面去看一看，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723407.png)

在按下`F6`快捷键让程序往下运行的过程中，我们可以看到，先是定义了一个保存可用增强器的LinkedList集合，即eligibleAdvisors。然后通过下面的一个for循环来遍历每一个增强器，在遍历的过程中，可以看到有两个&&判断条件，前面的那个是来判断每一个增强器是不是IntroductionAdvisor这种类型的，很明显，每一个增强器并不是这种类型的，它是InstantiationModelAwarePointcutAdvisor这种类型的，前面我也说过了。所以，程序压根就不会进入到这个if判断语句中。

程序继续往下运行，这时我们会看到还有一个for循环，它同样是来遍历每一个增强器的，在遍历的过程中，可以看到先是来判断每一个增强器是不是IntroductionAdvisor这种类型的，但很显然，并不是，然后再来利用canApply()方法判断每一个增强器是不是可用的，那什么是叫可用的呢？

我们可以按下`F5`快捷键进入canApply()方法里面去看一看，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723548.png)

在按下F6快捷键让程序往下运行的过程中，我们可以看到，这一块的逻辑就是用PointcutAdvisor（切入点表达式）开始来算一下每一个通知方法能不能匹配上，哈，现在每一个增强器（通知方法）都是能匹配上的哟！大家如果有兴趣的话，那么可以再深入研究下，但我想你肯定是没什么兴趣的，要看的东西太多了...

继续按下`F6`快捷键让程序往下运行，可以看到，现在程序是回到了findAdvisorsThatCanApply()方法的第二个for循环中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723680.png)

由于现在第一个增强器（logStart()方法）是能匹配上的，即它肯定是能切入到目标对象的目标方法中的，也就是说这个增强器是可用的，所以它会被添加到名为eligibleAdvisors的LinkedList集合里面。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723796.png)

继续按下`F6`快捷键让程序往下运行，就会循环判断接下来的每一个增强器能不能用，若能用则添加到名为eligibleAdvisors的LinkedList集合中。

接着，继续按下`F6`快捷键让程序往下运行，一直运行回findEligibleAdvisors()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643723904.png)

至此，终于**获取到能在当前bean中使用的增强器**了。

继续按下`F6`快捷键让程序往下运行，可以看到，在该方法中还对增强器做了一些排序，也就是说调用哪些通知方法，它们都是有顺序的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724147.png)

继续按下`F6`快捷键让程序往下运行，这时程序会运行回getAdvicesAndAdvisorsForBean()方法中，最终能在当前bean中使用的增强器就获取到了，要是没获取到呢（即advisors集合为空），那么就会返回一个DO_NOT_PROXY，这个DO_NOT_PROXY其实就是null。很显然，这儿是获取到了，advisors集合并不会为空，所以程序最终会运行到下面这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724357.png)

继续按下`F6`快捷键让程序往下运行，这时程序会运行回wrapIfNecessary()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724227.png)

现在这个叫specificInterceptors的`Object[]`数组里面已经具有了那些指定好的增强器，这些增强器其实就是要拦截目标方法执行的。

## 小结

以上这一小节的流程，我们可以归纳为：

1. 找到候选的所有增强器，也就是说是来找哪些通知方法是需要切入到当前bean的目标方法中的
2. 获取到能在当前bean中使用的增强器
3. 给增强器排序

## 保存当前bean在advisedBeans中，表示这个当前bean已经被增强处理了

接下来，继续按下`F6`快捷键让程序往下运行，当程序运行到下面这一行代码时，就会将当前bean添加到名为advisedBeans的Map集合中，表示这个当前bean已经被增强处理了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724685.png)

当程序继续往下运行时，会发现有一个createProxy()方法，这个方法非常重要，它是来创建代理对象的。

## 若当前bean需要增强，则创建当前bean的代理对象

当程序运行到createProxy()方法处时，就会创建当前bean的代理对象，那么这个代理对象怎么创建的呢？

当然是进入到该方法中去看一看了，按下F5快捷键进入当前方法中,如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724814.png)

继续按下`F6`快捷键让程序往下运行，运行到457这行代码处，可以看到是先拿到所有增强器，然后再把这些增强器保存到代理工厂（即proxyFactory）中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724880.png)

接下来，继续按下`F6`快捷键让程序往下运行，直至运行到createProxy()方法的最后一行，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643724924.png)

这行代码的意思是说，利用代理工厂帮我们创建一个代理对象，那它是怎么帮我们创建代理对象的呢？这得进入到代理工厂的getProxy()方法里面去看一看了，按下`F5`快捷键进入当前方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643725048.png)

可以看到，会先调用createAopProxy()方法来创建AOP代理。我们按下`F5`快捷键进入该方法中去看一看，如下图所示，可以看到是先得到AOP代理的创建工厂，然后再来创建AOP代理的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643725159.png)

我们继续按下`F5`快捷键进入当前方法中，再按下`F7`快捷键从当前方法里面退出来，getAopProxyFactory()方法就调用完了，也即AOP代理的创建工厂就获取到了。接下来，就是调用createAopProxy()方法为this对象创建AOP代理了。

那到底是怎么来创建创建AOP代理的呢？我们可以按下`F5`快捷键进入createAopProxy()方法中去看一看，如下图所示，这时Spring会自动决定，是为组件创建jdk的动态代理呢，还是为组件创建cglib的动态代理？

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643725247.png)

也就是说，会在这儿为组件创建代理对象，并且有两种形式的代理对象，它们分别是：

- 一种是JdkDynamicAopProxy这种形式的，即jdk的动态代理
- 一种是ObjenesisCglibAopProxy这种形式的，即cglib的动态代理

那么Spring是怎么自动决定是要创建jdk的动态代理，还是要创建cglib的动态代理呢？如果当前类是有实现接口的，那么就使用jdk来创建动态代理，如果当前类没有实现接口，例如MathCalculator类，此时jdk是没法创建动态代理的，那么自然就得使用cglib来创建动态代理了。而且，咱们可以让Spring强制使用cglib，关于这一点，后续如果有机会的话，那么我们再来探讨。

也就是说，不管怎么样，Spring都会在这儿为我们创建一个代理对象。很显然，现在是使用cglib来创建动态代理的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643725346.png)

我们继续按下`F6`快捷键让程序往下运行，一直让程序运行回wrapIfNecessary()方法中，如下图所示，这时createProxy()方法返回的proxy对象是一个通过Spring cglib增强了的代理对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643725528.png)

我们继续按下`F6`快捷键让程序往下运行，一直让程序运行到applyBeanPostProcessorsAfterInitialization()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643725580.png)

至此，刚才的那个wrapIfNecessary()方法就完全算是调用完了。

经过上面的分析，我们知道，**wrapIfNecessary()方法调用完之后，最终会给容器中返回当前组件使用cglib增强了的代理对象。**

对于MathCalculator这个组件来说，以后从容器中获取到的就是该组件的代理对象，然后在执行其目标方法时，这个代理对象就会执行切面里面的通知方法。

## 小结

以上这一小节的流程，我们可以归纳为：

1. 获取所有增强器，所谓的增强器就是切面里面的那些通知方法。
2. 然后再把这些增强器保存到代理工厂（即proxyFactory）中。
3. 为当前组件创建代理对象，并且会有两种形式的代理对象，它们分别如下，最终Spring会自动决定，是为当前组件创建jdk的动态代理，还是创建cglib的动态代理。
   - 一种是JdkDynamicAopProxy这种形式的，即jdk的动态代理
   - 一种是ObjenesisCglibAopProxy这种形式的，即cglib的动态代理

# 6. 目标方法的拦截逻辑

在上一讲中，咱们分析了一下，AnnotationAwareAspectJAutoProxyCreator作为后置处理器，它的作用是什么。这一讲，将关注点放在目标方法的拦截逻辑上，研究研究目标方法执行之前，它是如何被拦截的。

打开IOCTest_AOP测试类的代码，并在目标方法运行的地方打上一个断点，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643797401.png)

然后以debug模式来运行IOCTest_AOP测试类，这时，应该还是会来到AbstractAdvisorAutoProxyCreator抽象类的setBeanFactory()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643804370.png)

程序是怎么一步一步到这儿的，我想之前我已经说得够明白了，这里我就不再赘述一遍了。那接下来该怎么办呢？我们按下`F8`快捷键让程序运行到下一个断点，一直运行到这个即将要执行的目标方法处，也就是说我们以前看过的方法就直接跳过了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643804513.png)

当程序运行到目标方法处之后，我们就得进入该方法中来看一看其执行流程了。不过在此之前，我们来看一下从容器中得到的MathCalculator对象，可以看到它确实是使用cglib增强了的代理对象，它里面还封装了好多的数据，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643805406.png)

也就是说**容器中存放的这个增强后的代理对象里面保存了所有通知方法的详细信息，以及还包括要切入的目标对象。**

接下来，我们按下`F5`快捷键进入目标方法中去看一看，这时，应该是来到了System类的getSecurityManager()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643805675.png)

这儿牵扯到了jdk的那些类加载机制相关的东西，所以我们在这儿就不做过多研究了，再往下程序进入到了CglibAopProxy类的intercept()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643806078.png)

见名知义，这个方法就是来拦截目标方法的执行的。也就是说，在执行目标方法之前，先让这个AOP代理来拦截一下。接下来，我们就来看看它的拦截逻辑。

## 根据ProxyFactory对象获取将要执行的目标方法的拦截器链

在按下`F6`快捷键让程序往下运行的过程中，可以看到前面都是一些变量的声明，直至程序运行到下面这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643806189.png)

这时，就拿到了我们要切的目标对象，即MathCalculator对象。接下来，我们就得仔细研究一下getInterceptorsAndDynamicInterceptionAdvice()方法了。

这个方法是啥意思呢？它的意思是说要根据ProxyFactory对象获取将要执行的目标方法的拦截器链（chain，chain翻译过来就是链的意思），其中，advised变量代表的是ProxyFactory对象，method参数代表的是即将要执行的目标方法（即div()方法）。

那么，目标方法的拦截器链到底是怎么获取的呢？这才是我们关注的核心。听起来，它是来拦截目标方法前后进行执行的，而在目标方法前后要执行的，其实就是切面里面的通知方法。所以，我们可以大胆猜测，这个拦截器链应该是来说先是怎么执行通知方法，然后再来怎么执行目标方法的。

回到主题，如果有拦截器链，那么这个拦截器链是怎么获取的呢？我们可以按下`F5`快捷键进入getInterceptorsAndDynamicInterceptionAdvice()方法中去看一看，进来以后可以看到有一些缓存，缓存就是要把这些获取到的东西保存起来，方便下一次直接使用。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643806238.png)

然后按下`F6`快捷键让程序往下运行，直至运行到如下图所示的这行代码处。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643806276.png)

可以看到，它是利用advisorChainFactory来获取目标方法的拦截器链的。那又是怎么获取的呢？我们按下`F5`快捷键进入getInterceptorsAndDynamicInterceptionAdvice()方法中看一看便知道了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643806529.png)

可以看到，先是在开头创建一个List<Object> interceptorList集合，然后在后面遍历所有增强器，并为该集合添加值，最后返回该集合。最终，整个拦截器链就会被封装到List集合中。接下来，我就来详细讲讲getInterceptorsAndDynamicInterceptionAdvice()方法，看这个方法都做了些什么？

## 先创建一个List集合，来保存所有拦截器

注意，在开头创建List集合时，其实已经为该集合赋好了长度，长度到底是多少呢？inspect一下config.getAdvisors()表达式的值便知道了，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643806794.png)

很显然，该集合的长度是5，1个默认的ExposeInvocationInterceptor和4个增强器，这个List集合虽然有长度，但是现在是空的。另外，我们也知道，第一个增强器其实是一个异常通知，即AspectJAfterThrowingAdvice，因为我已在前面分析过了。

按下`F6`快捷键让程序往下运行，这时会有一个for循环，它是来遍历所有的Advisor的（一共有5个），每遍历出一个Advisor，便来判断它是不是PointcutAdvisor（和切入点有关的Advisor），若是则把这个Advisor传过来，然后包装成一个MethodInterceptor[]类型的interceptors，接着再把它添加到一开始创建的List集合中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807010.png)

如果遍历出的Advisor不是PointcutAdvisor，而是IntroductionAdvisor，那么怎么办呢？同样是将这个Advisor传过来，然后包装成一个`Interceptor[]`类型的interceptors，最后再把它添加到一开始创建的List集合中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807062.png)

或者，直接将遍历出的Advisor传进来，然后包装成一个`Interceptor[]`类型的interceptors，最后再把它添加到一开始创建的List集合中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807096.png)

## 遍历所有的增强器，将其转为Interceptor

我们按下`F6`快捷键让程序往下运行，让其运行到第61行代码处，即进入for循环中去遍历所有的Advisor。此时，inspect一下advisor变量的值，便能知道第一个增强器是ExposeInvocationInterceptor。

然后来判断这个Advisor是不是PointcutAdvisor，按下`F6`快捷键让程序继续往下运行，发现能进入到if判读语句中，说明这个Advisor确实是PointcutAdvisor。继续让程序往下运行，让其运行到第65行代码处，即：

```java
MethodInterceptor[] interceptors = registry.getInterceptors(advisor);
```

你可能要问了，遍历出每一个增强器之后，又是怎么将其转为Interceptor的呢？其实，答案就隐藏在上面这行代码中。

### 转换第一个增强器

我们按下`F5`快捷键进入getInterceptors()方法里面去一探究竟，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807507.png)

该方法的逻辑其实蛮简单的，就是先拿到增强器，然后判断这个增强器是不是MethodInterceptor这种类型的，若是则直接添加进名为interceptors的List集合里面，若不是则使用AdvisorAdapter（增强器的适配器）将这个增强器转为MethodInterceptor这种类型，然后再添加进List集合里面，反正不管如何，最后都会将该List集合转换成MethodInterceptor数组返回出去。

按下`F6`快捷键让程序往下运行，发现程序会进入到第一个if判断语句中，说明拿到的第一个增强器（即ExposeInvocationInterceptor）是MethodInterceptor这种类型的，那么自然就会将其添加进List集合中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807565.png)

继续按下`F6`快捷键让程序往下运行，当程序运行到第85行代码处时，inspect一下adapters变量的值，发现它里面有3个增强器的适配器，它们分别是：

1. MethodBeforeAdviceAdapter：专门来转前置通知的
2. AfterReturningAdviceAdapter：专门来返回置通知的
3. ThrowsAdviceAdapter：专门来异常置通知的

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807753.png)

此时，会使用到以上这3个增强器的适配器吗？并不会，因为程序继续往下运行的过程中，并不会进入到for循环里面的if判断语句中。

接着，让程序继续往下运行，直至getInterceptors()方法执行完毕，并且该方法运行完会返回一个MethodInterceptor数组，该数组只有一个元素，即拿到的第一个增强器（即ExposeInvocationInterceptor）。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643809301.png)

让程序继续往下运行，这时程序就运行回getInterceptorsAndDynamicInterceptionAdvice()方法中了，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643809522.png)

哎呀，第65行代码运行过去了，这不好，因为我们还想看看其他的增强器是怎么转成Interceptor的，那么这时该怎么办呢？我们可以点进getInterceptors()方法里面，然后在该方法处打上一个断点，接着便来看其他的增强器是怎么转成Interceptor的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643808132.png)

### 转换第二个增强器

此时，按下`F8`快捷键让程序运行到下一个断点，可以看到现在传递过来的是第二个Advisor，该Advisor持有的增强器是AspectJAfterThrowingAdvice，即异常通知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643809618.png)

在按下`F6`快捷键让程序往下运行的过程中，可以看到，先是判断拿到的第二个增强器是不是MethodInterceptor这种类型的。但很显然，它正好就是这种类型，你只要查看一下AspectJAfterThrowingAdvice类的源码便知道了，如下图所示，该类实现了MethodInterceptor接口。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643809692.png)

既然是，那么自然就会将其添加进List集合中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643807565.png)

继续按下`F6`快捷键让程序往下运行，此时，会使用到那3个增强器的适配器吗？并不会，因为程序继续往下运行的过程中，并不会进入到for循环里面的if判断语句中。

当程序运行至getInterceptors()方法的最后一行代码时，该方法会返回一个MethodInterceptor数组，并且该数组只有一个元素，即拿到的第二个增强器（即AspectJAfterThrowingAdvice）。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643809809.png)

### 转换第三个增强器

按下`F8`快捷键让程序运行到下一个断点，可以看到现在传递过来的是第三个Advisor，该Advisor持有的增强器是AspectJAfterReturningAdvice，即返回通知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643808610.png)

按下`F6`快捷键让程序往下运行，发现程序并不会进入到第一个if判断语句中，说明拿到的第三个增强器（即AspectJAfterReturningAdvice）并不是MethodInterceptor这种类型。也就是说有些通知方法是实现了MethodInterceptor接口的，也有些不是。 如果不是的话，那么该怎么办呢？这时，就要使用到增强器的适配器了。

让程序继续往下运行，可以看到现在使用的增强器的适配器是MethodBeforeAdviceAdapter，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643808674.png)

该适配器是专门来转前置通知的，它能不能支持转换这个AspectJAfterReturningAdvice（返回通知）呢？很显然是肯定不支持的。

接着，让程序继续往下运行，可以看到现在使用的增强器的适配器是AfterReturningAdviceAdapter，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643808779.png)

该适配器是专门来转返回通知的，很显然它肯定是支持转换这个AspectJAfterReturningAdvice（返回通知）的。那么，问题来了，该适配器是怎么将AspectJAfterReturningAdvice（返回通知）转换为Interceptor的呢？进入getInterceptor()方法里面一看便知，如下图所示，实际上就是拿到Advice（增强器），并将其包装成一个Interceptor而已。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643808831.png)

当程序运行至getInterceptors()方法的最后一行代码时，该方法会返回一个MethodInterceptor数组，并且该数组只有一个元素，即拿到的第三个增强器（即AfterReturningAdviceInterceptor）。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643808922.png)

### 转换第四个增强器

按下`F8`快捷键让程序运行到下一个断点，可以看到现在传递过来的是第四个Advisor，该Advisor持有的增强器是AspectJAfterAdvice，即后置通知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810184.png)

然后，按下`F6`快捷键让程序往下运行，发现程序会进入到第一个if判断语句中，说明拿到的第四个增强器（即AspectJAfterAdvice）是MethodInterceptor这种类型的，那么自然就会将其添加进List集合中。

继续按下`F6`快捷键让程序往下运行，此时，会使用到那3个增强器的适配器吗？并不会，因为程序继续往下运行的过程中，并不会进入到for循环里面的if判断语句中。

当程序运行至getInterceptors()方法的最后一行代码时，该方法会返回一个MethodInterceptor数组，并且该数组只有一个元素，即拿到的第四个增强器（即AspectJAfterAdvice）。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810512.png)

### 转换第五个增强器

按下`F8`快捷键让程序运行到下一个断点，可以看到现在传递过来的是第五个Advisor，该Advisor持有的增强器是AspectJMethodBeforeAdvice，即前置通知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810601.png)

然后，按下`F6`快捷键让程序往下运行，发现程序并不会进入到第一个if判断语句中，说明拿到的第五个增强器（即AspectJMethodBeforeAdvice）并不是MethodInterceptor这种类型。如果不是的话，那么该怎么办呢？这时，就要使用到增强器的适配器了。

让程序继续往下运行，可以看到现在使用的增强器的适配器是MethodBeforeAdviceAdapter，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810683.png)

该适配器是专门来转前置通知的，很显然它肯定是支持转换这个AspectJMethodBeforeAdvice（前置通知）的。该适配器是怎么转换的呢？其实很简单，就是拿到Advice（增强器），然后将其包装成一个Interceptor而已，这前面我也讲过了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810794.png)

当程序运行至getInterceptors()方法的最后一行代码时，该方法会返回一个MethodInterceptor数组，并且该数组只有一个元素，即拿到的第五个增强器（即MethodBeforeAdviceInterceptor）。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810888.png)

接着，让程序继续往下运行，将整个转换流程走完，直至程序运行回getInterceptorsAndDynamicInterceptionAdvice()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643810950.png)

紧接着，继续让程序往下运行，直至走完整个for循环，如下图所示，此时会返回一开始就创建的List集合。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643811082.png)

可以看到，该List集合里面有5个拦截器，其中AspectJAfterThrowingAdvice和AspectJAfterAdvice这俩人家本来就是拦截器，而AfterReturningAdviceInterceptor和MethodBeforeAdviceInterceptor这俩是使用适配器重新转换之后的拦截器。

最后，继续让程序往下运行，直至运行回CglibAopProxy类的intercept()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643811460.png)

此时，将要执行的目标方法的拦截器链就获取到了，**拦截器链里面保存的其实就是每一个通知方法**。

## 如果有拦截器链，那么怎么做呢？

**什么叫拦截器链呢？所谓的拦截器链其实就是每一个通知方法又被包装为了方法拦截器。** 之后，目标方法的执行，就要使用到这个拦截器链机制。

如果真的获取到了拦截器链，那么接下来会怎么做呢？很明显，这时程序会进入到else分支语句中，然后将需要执行的目标对象、目标方法以及拦截器链等所有相关信息传入CglibMethodInvocation类的有参构造器中，来创建一个CglibMethodInvocation对象，接着会调用其proceed()方法，并且该方法会有一个返回值。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643811877.png)

接下来，我们就来看看到底是怎么来new这个CglibMethodInvocation对象的。进入到CglibMethodInvocation匿名内部类的有参构造器中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/02/1643812129.png)

最后按下`F7`快捷键从当前方法里面退出来。至此，就new出来了这个CglibMethodInvocation对象。

new出来该对象以后，接下来就是来执行其proceed()方法了，相当于是来执行获取到的拦截器链，因为在new这个CglibMethodInvocation对象的时候，会把拦截器链传过来，传过来以后，势必就要执行该拦截器链了，而整个的执行过程其实就是触发拦截器链的调用过程。

## 如果没有拦截器链，那么直接执行目标方法

获取完拦截器链之后，如果这个链是空的，也就是说并没有获取到拦截器链，那么程序就会进入到if判断语句中执行如下这行代码。

```java
retVal = methodProxy.invoke(target, argsToUse);
```

这行代码的意思是什么呢？仔细看一下这行代码上面的注释，我们就能知道，它的意思是说将会跳过创建一个MethodInvocation对象，然后直接就来执行目标对象中的目标方法。

# 7. 拦截器链的执行过程

通过上一讲的研究，我们知道，在目标方法执行之前，Spring会把所有的增强器转换为拦截器，并最终形成一个拦截器链，然后根据这个拦截器链new出一个CglibMethodInvocation对象，接着会调用其proceed()方法。

接下来，我们就来探究一下这个proceed()方法到底怎么执行的，你只要搞清楚了，那么你必然就能知道整个拦截器链的执行过程。更具体一点的说，你会知道目标方法的整个执行流程，即目标方法是怎么一执行，然后先来执行前置通知，接着再是目标方法，紧接着再是后置通知，最后再是返回通知或者异常通知的。

## 拦截器链的执行过程

我们还是以debug模式来运行IOCTest_AOP测试类，这时，应该还是会来到AbstractAdvisorAutoProxyCreator抽象类的setBeanFactory()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/01/1643718302.png)

程序是怎么一步一步到这儿的，我想之前我已经说得够多的了，这里我就不再赘述一遍了。那接下来该怎么办呢？我们按下`F8`快捷键让程序运行到下一个断点，一直运行到这个即将要执行的目标方法处，也就是说我们以前看过的方法就直接跳过了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643891833.png)

然后我们继续按下`F8`快捷键让程序运行到下一个断点，这时程序会运行到DefaultAdvisorAdapterRegistry类的getInterceptors()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643891926.png)

你是不是现在倍感熟悉，因为此时就是将遍历出的每一个增强器转成拦截器的过程，我在上一讲中也详细讲过了

我们不妨点击方法调用栈的下面一行看看，如下图所示，inspect一下config.getAdvisors()表达式的值，便能看到那5个增强器了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892075.png)

还是回到DefaultAdvisorAdapterRegistry类的getInterceptors()方法中，继续按下F8快捷键让程序运行到下一个断点，反复4次之后，可以看到现在传递过来的是第五个Advisor，该Advisor持有的增强器是AspectJMethodBeforeAdvice，即前置通知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892244.png)

接下来，按下`F6`快捷键让程序往下运行，一直运行到CglibAopProxy类的intercept()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892409.png)

此时，将要执行的目标方法的拦截器链就获取到了。

如果真的获取到了拦截器链，那么接下来会怎么做呢？很明显，这时程序会进入到else分支语句中，然后将需要执行的目标对象、目标方法以及拦截器链等所有相关信息传入CglibMethodInvocation类的有参构造器中，来创建一个CglibMethodInvocation对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892492.png)

那到底是怎么来new这个CglibMethodInvocation对象的呢？我们进入到CglibMethodInvocation匿名内部类的有参构造器中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892630.png)

最后按下`F7`快捷键从当前方法里面退出来。至此，就new出来了这个CglibMethodInvocation对象。new出来该对象以后，接下来就是来执行其proceed()方法了。

以上就是上一讲中我们研究的内容。

接下来，我们就进去proceed()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，可以看到，这儿首先是有一个成员变量，即currentInterceptorIndex，翻译过来应该是当前拦截器的索引。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892709.png)

该索引的默认值是-1，点进该成员变量里面一看便知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892759.png)

然后，会在这儿做一个判断，即判断currentInterceptorIndex成员变量的值（也即索引的值）是否等于`this.interceptorsAndDynamicMethodMatchers.size() - 1`。你可能要问了，这个interceptorsAndDynamicMethodMatchers到底是什么啊？inspect一下它便知道了，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892934.png)

可以看到，interceptorsAndDynamicMethodMatchers其实就是一个ArrayList集合，它里面保存有5个拦截器。

也就是说，在这儿是来判断-1是否等于5-1的，很显然，并不相等。你又要问了，那什么时候相等呢？这得分两种情况来看：

1. 如果我们没有获取到拦截器链，那么该ArrayList集合必然就是空的，此时就相当于是在判断-1是否等于0-1
2. currentInterceptorIndex成员变量是来记录我们当前拦截器的索引的（从-1开始），有可能正好当前拦截器的索引为4，此时就相当于是在判断4是否等于5（拦截器总数）-1

不管是哪种情况，程序都会进入到if判断语句中。就以第一种情况来说，此时并没有拦截器链，那么必然就会调用invokeJoinpoint()方法。我们可以点进该方法里面去一探究竟，发现进入到了ReflectiveMethodInvocation类的invokeJoinpoint()方法中，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893097.png)

再点进invokeJoinpointUsingReflection()方法里面，发现其实就是利用反射来执行目标方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893193.png)

所以，我们可以得出这样一个结论：**如果没有拦截器链，或者当前拦截器的索引和拦截器总数-1的大小一样，那么便直接执行目标方法。** 我们先分析到这，因为过一会就可以看到这个过程了。

好，我们还是回到proceed()方法里面，此时是来判断currentInterceptorIndex成员变量的值（即-1）是否等于拦截器总数（5）-1的，很显然并不相等，所以程序并不会进入到if判断语句中。

按下`F6`快捷键让程序往下运行，运行至第162行代码处时，可以看到会先让currentInterceptorIndex成员变量自增，即由-1自增为0，然后再从拦截器链里面获取第0号拦截器，即ExposeInvocationInterceptor。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893339.png)

也就是说，在proceed()方法里面，我们会先来获取到第0号拦截器。第0号拦截器我们拿到以后，那么接下来该怎么办呢？继续按下`F6`快捷键让程序往下运行，发现运行到了第179行代码处，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893441.png)

可以看到，会调用当前拦截器的invoke()方法，而且会将this指代的对象传入该方法中。那么this指代的又是哪一个对象呢？inspect一下this，我们便知道它指代的就是之前创建的CglibMethodInvocation对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893525.png)

接下来，我们就进去invoke()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，可以看到，这儿是先从invocation里面get到一个MethodInvocation实例。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893578.png)

你不禁就要问了，这个invocation是啥？这个MethodInvocation又是啥？我来一一解答你的疑问，点击invocation成员变量进去看一下，可以看到它是一个ThreadLocal，ThreadLocal就是同一个线程来共享数据的，它要共享的数据就是MethodInvocation实例，而这个MethodInvocation实例其实就是之前创建的CglibMethodInvocation对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893637.png)

由于这是第一次，ThreadLocal里面还没有共享数据，因此接下来便会在当前线程中保存CglibMethodInvocation对象。然后就会来执行CglibMethodInvocation对象的proceed()方法，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643893699.png)

说白了，**执行拦截器的invoke()方法其实就是执行CglibMethodInvocation对象的proceed()方法。**

接下来，我们就再进去proceed()方法里面去看一看，它到底是怎么执行的。按下F5快捷键进入该方法中，你会发现这又是同样熟悉的那套，只不过现在是来判断currentInterceptorIndex成员变量的值（即0，因为自增过一次，所以已经由之前的-1变成了0）是否等于拦截器总数（5）-1的，很显然并不相等，所以程序并不会进入到if判断语句中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892709.png)

继续按下`F6`快捷键让程序往下运行，运行至第162行代码处时，可以看到会先让currentInterceptorIndex成员变量自增，即由0自增为1，然后再从拦截器链里面获取第1号拦截器，即AspectJAfterThrowingAdvice。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894009.png)

也就是说，**每执行一次proceed()方法，当前拦截器的索引（即currentInterceptorIndex成员变量）都会自增一次。**

第1号拦截器我们拿到以后，那么接下来该怎么办呢？继续按下`F6`快捷键让程序往下运行，发现运行到了第179行代码处，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894069.png)

可以看到，又会调用当前拦截器的invoke()方法，并且会将CglibMethodInvocation对象传入该方法中。

这时，你会发现，现在是从第一个拦截器（即ExposeInvocationInterceptor）锁定到了下一个拦截器（即AspectJAfterThrowingAdvice），而且我们也看到了，所有拦截器都会调用invoke()方法。

接着，我们就再进去invoke()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，可以看到，当前拦截器（即AspectJAfterThrowingAdvice）的invoke()方法的执行逻辑是下面这样子的。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894124.png)

可以看到又是来调用CglibMethodInvocation对象的proceed()方法，其中mi变量指代的就是CglibMethodInvocation对象。

至此，我们可以得出这样一个结论：**每执行一次proceed()方法，当前拦截器的索引（即currentInterceptorIndex成员变量）都会自增一次，并且还会拿到下一个拦截器。这个流程会不断地循环往复，直至拿到最后一个拦截器为止。**

接下来，我们就再进去proceed()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，你会发现又是同样熟悉的那套，只不过现在是来判断currentInterceptorIndex成员变量的值（即1，因为自增过一次，所以已经由之前的0变成了1）是否等于拦截器总数（5）-1的，很显然并不相等，所以程序并不会进入到if判断语句中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892709.png)

继续按下`F6`快捷键让程序往下运行，运行至第162行代码处时，可以看到会先让currentInterceptorIndex成员变量自增，即由1自增为2，然后再从拦截器链里面获取第2号拦截器，即AfterReturningAdviceInterceptor。

<img src="https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894359.png" alt="desc"  />

第2号拦截器我们拿到以后，那么接下来该怎么办呢？继续按下`F6`快捷键让程序往下运行，发现运行到了第179行代码处，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894464.png)

可以看到，又会调用当前拦截器的invoke()方法，并且会将CglibMethodInvocation对象传入该方法中。

这时，你会发现，现在是从上一个拦截器（即AspectJAfterThrowingAdvice）锁定到了当前这个拦截器（即AfterReturningAdviceInterceptor），可想而知，当前这个拦截器又该要锁定到下一个拦截器了。

接着，我们就再进去invoke()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，可以看到，又是来调用CglibMethodInvocation对象的proceed()方法，其中mi变量指代的就是CglibMethodInvocation对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894551.png)

接下来，我们就再进去proceed()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，你会发现又是同样熟悉的那套，只不过现在是来判断currentInterceptorIndex成员变量的值（即2，因为自增过一次，所以已经由之前的1变成了2）是否等于拦截器总数（5）-1的，很显然并不相等，所以程序并不会进入到if判断语句中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892709.png)

继续按下`F6`快捷键让程序往下运行，运行至第162行代码处时，可以看到会先让currentInterceptorIndex成员变量自增，即由2自增为3，然后再从拦截器链里面获取第3号拦截器，即AspectJAfterAdvice。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894742.png)

第3号拦截器我们拿到以后，那么接下来该怎么办呢？继续按下`F6`快捷键让程序往下运行，发现运行到了第179行代码处，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894904.png)

可以看到，又会调用当前拦截器的invoke()方法，并且会将CglibMethodInvocation对象传入该方法中。

这时，你会发现，现在是从上一个拦截器（即AfterReturningAdviceInterceptor）锁定到了当前这个拦截器（即AspectJAfterAdvice），可想而知，当前这个拦截器又该要锁定到下一个拦截器了。

接着，我们就再进去invoke()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，可以看到，又是来调用CglibMethodInvocation对象的proceed()方法，其中mi变量指代的就是CglibMethodInvocation对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643894983.png)

现在，你是否明白了这样一个道理，就是**invoke()方法里面会调用proceed()方法，而这个proceed()方法又是寻找下一个拦截器**？

接下来，我们就再进去proceed()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，你会发现又是同样熟悉的那套，只不过现在是来判断currentInterceptorIndex成员变量的值（即3，因为自增过一次，所以已经由之前的2变成了3）是否等于拦截器总数（5）-1的，很显然并不相等，所以程序并不会进入到if判断语句中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892709.png)

继续按下`F6`快捷键让程序往下运行，运行至第162行代码处时，可以看到会先让currentInterceptorIndex成员变量自增，即由3自增为4，然后再从拦截器链里面获取第4号拦截器，即MethodBeforeAdviceInterceptor，它已是最后一个拦截器了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895217.png)

最后一个拦截器我们拿到以后，那么接下来该怎么办呢？继续按下`F6`快捷键让程序往下运行，发现运行到了第179行代码处，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895256.png)

可以看到，又会调用当前拦截器的invoke()方法，并且会将CglibMethodInvocation对象传入该方法中。

这时，你会发现，现在是从上一个拦截器（即AspectJAfterAdvice）锁定到了当前最后这个拦截器（即MethodBeforeAdviceInterceptor）。

接着，我们就再进去invoke()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，可以看到，现在这个invoke()方法里面的逻辑有点变化，它会先调用前置通知，再来调用CglibMethodInvocation对象的proceed()方法，其中mi变量指代的就是CglibMethodInvocation对象。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895299.png)

## 调用前置通知

继续按下`F6`快捷键让程序往下运行，会发现MethodBeforeAdviceInterceptor这个拦截器总算是做一点事了，即调用前置通知，并且IDEA控制台也打印出了前置通知要输出的内容，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895393.png)

前置通知调用完之后，会再来调用CglibMethodInvocation对象的proceed()方法。

接下来，我们就再进去proceed()方法里面去看一看，它到底是怎么执行的。按下`F5`快捷键进入该方法中，你会发现又是同样熟悉的那套，只不过现在是来判断currentInterceptorIndex成员变量的值（即4，因为自增过一次，所以已经由之前的3变成了4）是否等于拦截器总数（5）-1的，很显然是相等的，所以程序会进入到if判断语句中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643892709.png)

这时，会直接利用反射来执行目标方法。继续按下`F6`快捷键让程序往下运行，你会看到IDEA控制台打印出了目标方法中要输出的内容，这表明目标方法已执行完了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895548.png)

也就是说，**前置通知调用完之后，接着是来调用目标方法的，并且目标方法调用完之后会返回到上一个拦截器（即AspectJAfterAdvice）中。**

## 调用后置通知

执行完目标方法并返回到上一个拦截器（即AspectJAfterAdvice）中之后，可以看到会在finally代码块中执行后置通知，因为AspectJAfterAdvice是一个后置通知的拦截器。

继续按下`F6`快捷键让程序往下运行，你会看到Eclipse控制台打印出了后置通知要输出的内容，这表明当前拦截器（即AspectJAfterAdvice）的invoke()方法就调用完了。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895606.png)

从上图中可以知道，调用完后置通知之后，再次返回到了第二个拦截器（即AspectJAfterThrowingAdvice）中。

## 如果目标方法运行时没有抛异常，那么调用返回通知

如果目标方法运行时没有抛异常，那么后置通知调用完之后，就应该返回到第三个拦截器（即AfterReturningAdviceInterceptor）中。

而目前的这个目标方法运行时抛了异常，那么在调用完后置通知之后，其实按理来说应该是要返回到第三个拦截器（即AfterReturningAdviceInterceptor）中的，但是这个拦截器并没有对异常进行处理，而是直接抛给了上一个拦截器（即AspectJAfterThrowingAdvice），所以，你会看到，最终是返回到了第二个拦截器（即AspectJAfterThrowingAdvice）中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895606.png)

在这个拦截器的invoke()方法中才有catch语句捕获到异常。

我们可以来看一下AfterReturningAdviceInterceptor这个拦截器的invoke()方法，看看它到底是怎么执行的，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895890.png)

可以看到，只有下面这行代码执行时没有问题，才会调用返回通知。

```java
Object retVal = mi.proceed();
```

而且，咱们在以上invoke()方法中，并没有看到try catch代码块，所以，一旦以上代码运行时抛了异常，那么便会直接抛给上一个拦截器。

也就是说，**返回通知只有在目标方法运行没抛异常的时候才会被调用。**

## 如果目标方法运行时抛异常，那么调用异常通知

但是，现在目标方法运行时抛了异常，所以在后置通知调用完之后，返回到了第三个拦截器（即AfterReturningAdviceInterceptor）中。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643895972.png)

该拦截器捕获到异常之后，便会调用异常通知。按下`F6`快捷键让程序往下运行，你会看到IDEA控制台打印出了异常通知要输出的内容，如下图所示。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643896051.png)

异常通知调用完之后，如果有异常，整个的这个异常还会被抛出去，而且是一层一层地往上抛，有人处理就处理，没人处理就抛给虚拟机。

至此，整个拦截器链的执行过程，我们就知道的非常清楚了。更具体一点的说，我们知道了目标方法的整个执行流程，即先执行前置通知，然后再来执行目标方法，接着再来执行后置通知，这三步是固定的。最后，如果目标方法运行时没有抛异常，那么调用返回通知，如果目标方法运行时抛了异常，那么调用异常通知。

![desc](https://cdn.jsdelivr.net/gh/zsxfa/CDN/img/md/2022/02/03/1643896113.png)

## 小结

整个拦截器链的执行过程，我们总结一下，其实就是链式获取每一个拦截器，然后执行拦截器的invoke()方法，每一个拦截器等待下一个拦截器执行完成并返回以后，再来执行其invoke()方法。通过拦截器链这种机制，保证了通知方法与目标方法的执行顺序。

# AOP原理总结

经过前面这7讲的学习，相信对AOP的原理有了一个更深入的认识，而且还是从源码角度去认识的。

最后，我们还需要对AOP原理做一个简单的总结，完美结束对其研究的旅程。

1. 利用@EnableAspectJAutoProxy注解来开启AOP功能

2. 这个AOP功能是怎么开启的呢？主要是通过@EnableAspectJAutoProxy注解向IOC容器中注册一个AnnotationAwareAspectJAutoProxyCreator组件来做到这点的

3. AnnotationAwareAspectJAutoProxyCreator组件是一个后置处理器

4. 该后置处理器是怎么工作的呢？在IOC容器创建的过程中，我们就能清楚地看到这个后置处理器是如何创建以及注册的，以及它的工作流程。

   **a.** 首先，在创建IOC容器的过程中，会调用refresh()方法来刷新容器，而在刷新容器的过程中有一步是来注册后置处理器的，如下所示：

   ```java
   registerBeanPostProcessors(beanFactory); // 注册后置处理器，在这一步会创建AnnotationAwareAspectJAutoProxyCreator对象
   ```

   其实，这一步会为所有后置处理器都创建对象。

   **b.** 在刷新容器的过程中还有一步是来完成BeanFactory的初始化工作的，如下所示：

   ```java
   finishBeanFactoryInitialization(beanFactory); // 完成BeanFactory的初始化工作。所谓的完成BeanFactory的初始化工作，其实就是来创建剩下的单实例bean的。
   ```

   很显然，剩下的单实例bean自然就包括MathCalculator（业务逻辑类）和LogAspects（切面类）这两个bean，因此这两个bean就是在这儿被创建的。

   - 创建业务逻辑组件和切面组件

   - 在这两个组件创建的过程中，最核心的一点就是AnnotationAwareAspectJAutoProxyCreator（后置处理器）会来拦截这俩组件的创建过程

   - 怎么拦截呢？主要就是在组件创建完成之后，判断组件是否需要增强。如需要，则会把切面里面的通知方法包装成增强器，然后再为业务逻辑组件创建一个代理对象。我们也认真仔细探究过了，在为业务逻辑组件创建代理对象的时候，使用的是cglib来创建动态代理的。当然了，如果业务逻辑类有实现接口，那么就使用jdk来创建动态代理。一旦这个代理对象创建出来了，那么它里面就会有所有的增强器。

     这个代理对象创建完以后，IOC容器也就创建完了。接下来，便要来执行目标方法了。

5. 执行目标方法

   **a.** 此时，其实是代理对象来执行目标方法

   **b.** 使用CglibAopProxy类的intercept()方法来拦截目标方法的执行，拦截的过程如下：

   - 得到目标方法的拦截器链，所谓的拦截器链其实就是每一个通知方法又被包装为了方法拦截器，即MethodInterceptor

   - 利用拦截器的链式机制，依次进入每一个拦截器中进行执行

   - 最终，整个的执行效果就会有两套：

     > 目标方法正常执行：前置通知→目标方法→后置通知→返回通知
     >
     > 目标方法出现异常：前置通知→目标方法→后置通知→异常通知



